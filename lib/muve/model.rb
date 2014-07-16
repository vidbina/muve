module Muve
  # Muve models imitate some behavior that one may commonly expect of typical
  # models. There are mechanisms in place for storing, modifying, retrieving 
  # and the removing of resources.
  #
  # In order to make this a flexible solution, models never take care of 
  # handling the persisting of the resources they manange. That part of the 
  # lifing is dispatched to the +Model::Store+ which may be though of as
  # an adaptor.
  module Model
    include MuveError
    
    def initialize(params={})
      @new_record = true
      @destroyed = false
      # TODO: figure out how to best set this
      # Have all models in an app to run on the same adaptor
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def self.init(adaptor=nil)
      @@adaptor = adaptor
    end

    def self.handler
      @@adaptor
    end

    # Attempts to save a resource and raises an error on failure
    def save!
      create_or_update || raise(MuveSaveError)
    end
  
    # Attempts to save a resource
    def save
      create_or_update
    end

    def destroy
      if adaptor.delete(container, id)
        @destroyed = true 
      end
    end

    # TODO: setup a peristed? method
    def new_record?
      @new_record = true if @new_record.nil?
      @new_record
    end

    def persisted?
      !(new_record? || destroyed?)
    end

    def destroyed?
      @destroyed
    end
  
    def valid?
      false
    end
  
    def invalid?
      !valid?
    end
  
    private
    def create_or_update
      result = new_record? ? create(attributes) : update(attributes)
    end

    # TODO: implement
    def attributes
      {}
    end

    def create(attr)
      adaptor.create(container, attr)
    end

    def update(attr)
      adaptor.update(container, id, attr)
    end

    def adaptor
      self.class.adaptor
    end

    def container
    end

    def id
      @id
    end

    def details
    end

    module ClassMethods
      def adaptor=(adaptor)
        @@adaptor = adaptor
      end
  
      def adaptor
        @@adaptor
      end

      def find(id)
        self.adaptor.get(self, id)
      end

      def where(params)
        self.adaptor.get(self, nil, params)
      end
    end
  end
end
