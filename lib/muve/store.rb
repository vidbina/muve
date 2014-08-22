module Muve
  # Muve::Store takes care of resource persistence and retrieval. Use stores
  # as adaptors to connect your implementation of Muve to whichever datastore
  # you please.
  #
  # Adaptors or Stores only take of the interaction with the datastore but 
  # leave the model's housekeeping up the respective model. Make sure to 
  # conform to the expected return formats for the different adaptor methods.
  #
  # Take a look at +Muve::Store::Mongo+ to find an implementation of a store
  # adaptor.
  module Store
    include MuveError
    include Muve::Helper

    # gets data from the given container matching the provided details
    #
    # Given a +Place+ resource the following calls may be acceptable
    # - +Adaptor.get(Place, 1232) # find one resource where id = 1232+
    # - +Adaptor.get(Place, nil, { city: 'NYC', rating: 5 })+ # find more
    def get(resource, id=nil, details=nil)
      raise MuveInvalidQuery unless id || details

      if details
        find(resource, details)
      else
        fetch(resource, id, {})
      end
    end

    # creates a resource containing the specified details in the repository.
    # Returns the id of the created object on success, raises an error otherwise
    def create(resource, details)
      raise MuveIncompleteImplementation, "implement a create handler for #{self}"
    end

    # removes a resource matching the optional +id+ and +details+ 
    # from the repository.
    # A successful removal operation should returns +true+ while any other 
    # value is considered an error.
    def delete(resource, id, details=nil)
      raise MuveIncompleteImplementation, "implement a delete handler for #{self}"
    end

    # update a resource with the identified by +id+ with the given +details+
    def update(resource, id, details)
      raise MuveIncompleteImplementation, "implement a update handler for #{self}"
    end

    # collect a single resource from the repository that matches the given id 
    # and details. Upon the successful retrieval of a resource the id of the 
    # resource is presented under the key +id+ while other attributes of the 
    # resource bear arbitrary names.
    #
    #   { id: 12, name: 'Spock', organization: 'The Enterprise' }
    def fetch(resource, id, details={})
      raise MuveIncompleteImplementation, "implement a fetch handler for #{self}"
    end

    # find resources from its repository that match the given id and details
    # Returns an +Enumerator+ that returns a hash with the key +id+ containing
    # the primary key for the respective resource.
    #
    #   def find(resource, details)
    #     details = {} unless details.kind_of? Hash
    #     Enumerator.new do |item|
    #       fetched_result_from_datastore.each do |data|
    #         item << format_data(data) # format_data composes the required hash 
    #       end
    #     end
    #   end
    def find(resource, details)
      raise MuveIncompleteImplementation, "implement a find handler for #{self}"
    end

    # counts the resources matching the details, if any.
    # Returns a integer that represents the amount of matching entities found.
    def count(resource, details={})
      raise MuveIncompleteImplementation, "implement a count handler for #{self}"
    end

    alias_method :destroy, :delete
    alias_method :remove, :delete

    # composes the id hash for the used store. Some in some cases the index
    # is the +id+ or +_id+ field, while in other cases the index field may be
    # different. The store should take care of index naming.
    def index_hash(index_values)
      {}
    end
  end
end
