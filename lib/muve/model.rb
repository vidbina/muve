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
      create_or_update || raise(MuveSaveError)
    end
  
    # Save a resource
    def save
      create_or_update
    end

    # Destroy a resource
    def destroy
      if adaptor.delete(container, id) == true
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
        self.public_send "#{attr}=", value
      end

      @new_record = false if details.key? :id
    end

    def create_or_update
      result = new_record? ? create(attributes) : update(attributes)
    end

    # TODO: implement
    def attributes
      {}
    end

    def create(attr)
      @id = adaptor.create(container, attr)
      @new_record = false
      self
    end

    def update(attr)
      adaptor.update(container, id, attr)
      self
    end

    def adaptor
      self.class.adaptor
    end

    def container
    end

    def details
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
        raise MuveError::MuveNotConfigured, "container not configured"
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
        self.new(self.adaptor.get(self, nil, params))
      end
    end
  end
end
