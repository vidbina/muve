module Muve
  # Store takes care of storing 
  module Store
    include MuveError

    # gets data from the given container matching the provided details
    def get(container, id=nil, details=nil)
      raise MuveInvalidQuery unless id || details

      if details
        find(container, details)
      else
        fetch(container, id, details)
      end
    end

    # creates a resource containing the specified details in the given container 
    def create(container, details)
    end

    # removes a resource matching the specified id and details from the given container
    def delete(container, id, details=nil)
    end

    # update a resource with the given id to the given details
    def update(container, id, details)
    end

    # collect resources from the container that match the given id and details
    # NOTE: fetch and find make little sense here
    def fetch(container, id, details={})
    end

    # find resources from the container that match the given id and details
    def find(container, details)
    end

    alias_method :destroy, :delete
    alias_method :remove, :delete
  end
end
