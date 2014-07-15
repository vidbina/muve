module Muve
  class Traveller
    include Model
  
    attr_accessor :id
  
    def initialize(id=nil)
      @id = id
    end
  
    def valid?
      !id.nil?
    end
  end
end
