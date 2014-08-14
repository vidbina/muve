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
    include MuveError
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
    def self.init(adaptor=nil)
      @@adaptor = adaptor
    end

    # Returns the adaptor set to handle retrieval and storage of resources
    def self.handler
      @@adaptor
    end

    # Save a resource and raises an MuveSaveError on failure
    def save!
      create_or_update
    rescue => e
      raise MuveSaveError, "Save failed because #{e} was raised"
    end
  
    # Save a resource
    def save
      create_or_update
    rescue => e
      false
    end

    # Destroy a resource
    def destroy
      if adaptor.delete(self.class.container, id) == true
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

    def create_or_update
      result = new_record? ? create(attributes) : update(attributes)
      self
    end

    # NOTE: not sure we need this
    def attributes
      data = {}
      fields.select{ |k| k != invalid_attributes }.each { |k| 
        data[k.to_sym] = self.public_send(k) 
      }
      data
    end

    def fields
      []
    end

    # Creates the record and performs the necessary housekeeping (e.g.: setting
    # the new id and un-marking the new_record?
    def create(attr)
      @id = adaptor.create(self.class.container, attr)
      @new_record = false
    end

    # TODO: Update the record and return the number of modified rows
    def update(attr)
      adaptor.update(self.class.container, id, attr)
    end

    def adaptor
      self.class.adaptor
    end

    # Class methods exposed to all Muve models
    module ClassMethods
      # Configure the adaptor to take care of handling persistence for this
      # model. The adaptor should extend +Muve::Store+.
      #
      # Adaptors provide an abstraction layer between Muve models and the actual 
      # datastore. This provides some flexibility in design as one may exchange
      # an adaptor for another in order to support another database technology 
      # (.e.g: swithing between document databases or relational databases)
      def adaptor=(adaptor)
        @@adaptor = adaptor
      end
  
      # The adaptor currently set to handle persistence for all Muve::Model
      # classes and instances
      def adaptor
        @@adaptor
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
        raise MuveError::MuveNotConfigured, "container not defined for #{self}"
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

      # Creates a new resource and persists it to the datastore
      def create(attributes)
        resource = self.new(attributes)
        resource.save if resource
        resource
      end
    end
  end
end
