module Muve
  # Muve::Store takes care of resource persistence and retrieval. Use stores
  # as adaptors to connect your implementation of Muve to whichever datastore
  # you please.
  module Store
    include MuveError

    # gets data from the given container matching the provided details
    def get(resource, id=nil, details=nil)
      raise MuveInvalidQuery unless id || details

      if details
        find(resource, details)
      else
        fetch(resource, id, {})
      end
    end

    # creates a resource containing the specified details in the given container 
    # Returns the id of the created object on success, raises an error otherwise
    def create(resource, details)
      raise MuveIncompleteImplementation, "implement a create handler for #{self}"
    end

    # removes a resource matching the specified id and details from the given container
    # A successful removal operation should return true while any other value
    # is considered an error.
    def delete(resource, id, details=nil)
      raise MuveIncompleteImplementation, "implement a delete handler for #{self}"
    end

    # update a resource with the given id to the given details
    def update(resource, id, details)
      raise MuveIncompleteImplementation, "implement a update handler for #{self}"
    end

    # collect resources from the repository that match the given id and details
    # Upon the successful retrieval of a resource the id of the resource is
    # presented under the key +id+ whilst the other attributes of the resource 
    # are presented with keys named accordingly.
    #
    # +{ id: 12, name: 'Spock', organization: 'The Enterprise' }+
    # --
    # NOTE: fetch and find make little sense here
    # ++
    def fetch(resource, id, details={})
      raise MuveIncompleteImplementation, "implement a fetch handler for #{self}"
    end

    # find resources from its repository that match the given id and details
    def find(resource, details)
      raise MuveIncompleteImplementation, "implement a find handler for #{self}"
    end

    alias_method :destroy, :delete
    alias_method :remove, :delete
  end
end
