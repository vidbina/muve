module Muve
  class Location
    include Model
  
    attr_accessor :latitude, :longitude
  
    alias_method :lat,   :latitude
    alias_method :lat=,  :latitude=
    alias_method :lon,   :longitude
    alias_method :lon=,  :longitude=
    alias_method :lng,   :longitude
    alias_method :lng=,  :longitude=
    alias_method :long,  :longitude
    alias_method :long=, :longitude=
  
    def initialize(latitude=nil, longitude=nil, type=:wgs84)
      @latitude, @longitude = latitude, longitude
    end
  
    def valid?
      return false unless latitude.abs <= 90 && longitude.abs <= 180
      true
    end
  
    def invalid?
      !valid?
    end
  
    def random(center, range)
    end
  end
end
