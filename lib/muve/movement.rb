module Muve
  class Movement
    include Model
  
    attr_accessor :traveller, :traveller_id, :location, :time
  
    def initialize(traveller=nil, location=nil, time=Time.now)
      @traveller, @location, @time = traveller, location, time
    end
  
    def valid?
      assocs.each do |assoc|
        return false unless !assoc.nil? && assoc.valid?
      end
      flds.each do |field|
        return false unless time
      end
      true
    end
  
    private
    def assocs
      [
        @traveller,
        @location
      ]
    end
  
    def flds
      [
        @time
      ]
    end
  end
end
