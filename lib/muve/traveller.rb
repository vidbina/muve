module Muve
  class Traveller
    include Model
  
    with_fields :id
  
    def initialize(id=nil)
      @id = id
    end
  
    def valid?
      !id.nil?
    end
  end
end
