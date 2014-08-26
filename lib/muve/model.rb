module Muve
  # Muve models imitate some behavior that one may commonly expect of typical
  # models. There are mechanisms in place for creation, modification, retrieval 
  # and the removal of resources.
  #
  # In order to make this a flexible solution, models never take care of 
  # handling the persisting of the resources they manange. That part of the 
  # lifing is dispatched to the +Model::Store+ object which may be though of 
  # as an adaptor.
  #
  # --
  # TODO: Include ActiveRecord::Model instead of using this tedious
  # implementation
  # ++
  module Model
    include Muve::Error
    include Muve::Helper
    
    def initialize(params={})
      params = {} unless params
      params.each do |attr, value|
        next if invalid_attributes.include? attr.to_s
        self.public_send "#{attr}=", value
      end

      @new_record = true
      @destroyed = false
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # Initializes the +Muve::Model+ class. Use the +Muve::Model::init+ method 
    # to set a adaptor to take care of the retrieval and storage of resources.
    def self.init(handler=nil)
      @handler = handler if handler
    end

    def self.handler
      @handler
    end

    # Returns a hash of the object and subsequently
    # containing objects that respond to #to_hash.
    # In order to avoid circular reference hell you
    # can set the limit.
    #
    # By default on the the root object and its 
    # children a explored. Everything beyond that
    # range is discarded.
    def to_hash(level=0, limit=1)
      hash = {}
      attributes.map { |k, v|
        if v.respond_to? :to_hash
          (hash[k] = v.to_hash(level+1, limit)) if level < limit
        else
          #(raise AssocError, "#Associated #{v.class} for #{k} must respond to #to_hash or be a Hash") unless v.kind_of? Hash
          hash[k] = v
        end
      }
      hash
    end

    # Save a resource and raises an SaveError on failure
    def save!
      create_or_update
    rescue => e
      e.backtrace.each { |err| p err }
      raise SaveError, "Save failed because #{e} was raised"
    end
  
    # Save a resource
    def save
      # TODO: be more verbose about the nature of the failure, if any
      raise ValidationError, "validation failed" unless valid?
      create_or_update
    end

    # Destroy a resource
    def destroy
      if adaptor.delete(self.class, id) == true
        @destroyed = true 
      end
    end

    # Returns true if the resource has recently been instantiated but not yet
    # written to the data store.
    def new_record?
      @new_record = true if @new_record.nil?
      @new_record
    end

    # Returns true if the resource is not newly instantiated or recently 
    # destroyed.
    def persisted?
      !(new_record? || destroyed?)
    end

    # Returns true if the resource in question has been destroyed
    def destroyed?
      @destroyed
    end
  
    # Returns a true if the resource passes all validations
    def valid?
      false
    end
  
    # Returns true if the resource fails any validation
    def invalid?
      !valid?
    end

    def id
      @id
    end
  
    private
    def invalid_attributes
      %w(id adaptor)
    end

    def populate(details)
      details = {} unless details

      @id = details[:id] if details.key? :id

      details.each do |attr, value|
        next if invalid_attributes.include? attr.to_s
        self.public_send "#{attr}=", value if fields.include? attr.to_sym
      end

      @new_record = false if details.key? :id
    end

    def serialized_attributes
      to_hash
    end

    def create_or_update
      result = new_record? ? create(serialized_attributes) : update(serialized_attributes)
      self
    end

    # NOTE: not sure we need this
    def attributes
      self.class.extract_attributes(
        resource: self,
        fields: fields,
        invalid_attributes: invalid_attributes,
        id: self.id
      )
    end

    # A manifest of the fields known to the model. The model logic seeks 
    # counsel from this resource to determine which properties to write and 
    # read from the repository.
    def fields
      []
    end

    # Creates the record and performs the necessary housekeeping (e.g.: setting
    # the new id and un-marking the new_record?
    def create(attr)
      @id = adaptor.create(self.class, attr)
      @new_record = false
    end

    # TODO: Update the record and return the number of modified rows
    def update(attr)
      adaptor.update(self.class, id, attr)
    end

    def adaptor
      self.class.adaptor
    end

    # Class methods exposed to all Muve models
    module ClassMethods
      include Muve::Error
      # Configure the adaptor to take care of handling persistence for this
      # model. The adaptor should extend +Muve::Store+.
      #
      # Adaptors provide an abstraction layer between Muve models and the actual 
      # datastore. This provides some flexibility in design as one may exchange
      # an adaptor for another in order to support another database technology 
      # (.e.g: swithing between document databases or relational databases)
      def adaptor=(adaptor)
        @adaptor = adaptor
      end
  
      # The adaptor currently set to handle persistence for all Muve::Model
      # classes and instances
      def adaptor
        raise MuveNotConfigured, "the adaptor has not been set" unless (@adaptor || Model.handler)
        @adaptor or Model.handler
      end

      def connection
        Muve::Model.connection
      end

      def database
        Muve::Model.database
      end
  
      # The container (e.g.: collection, tablename or anything that is analogous
      # to this construct) of the resource
      def container
        raise Muve::Error::NotConfigured, "container not defined for #{self}"
      end

      def extract_attributes(resource: self.new, fields: [], invalid_attributes: [], id: nil)
        data = {}
        fields.select{ |k| k != invalid_attributes }.each { |k| 
          # TODO: confirm resource.respond_to? k prior to assigning
          data[k.to_sym] = resource.public_send(k)
        }
        if id
          data = data.merge(resource.class.adaptor.index_hash id)
        end
        data
      end

      # Finds a resource by id
      def find(id)
        result = self.new()
        result.send(:populate, self.adaptor.get(self, id))
        result
      end

      # Querries the resource repository for all resources that match the
      # specified parameters.
      def where(params)
        Enumerator.new do |item|
          (self.adaptor.get(self, nil, params) or []).each do |details|
            details
            result = self.new()
            result.send(:populate, details)
            item << result
          end
        end
      end

      # Counts the amount of records that match the parameters
      def count(params={})
        self.adaptor.count(self, params)
      end
  
      # The +with_field+ helper allows one to declare a functioning model 
      # with less lines of code.
      #
      # Instead of declaring +attr_accessor :name, :age, :hat_size+ along with
      # the required private +#fields# method one may specify the known fields
      # of the resource with one line of code.
      def with_fields(*args)
        attr_accessor *args
        class_eval "def fields; #{args}; end"
      end

      # Creates a new resource and persists it to the datastore
      def create(attributes)
        resource = self.new(attributes)
        resource.save if resource
        resource
      end

      def destroy_all
        warn "Destroying of all entities for a resource is not implemented"
      end
    end
  end
end
