module Muve
  class Location
    include Model
  
    with_fields :latitude, :longitude
  
    alias_method :lat,   :latitude
    alias_method :lat=,  :latitude=
    alias_method :lon,   :longitude
    alias_method :lon=,  :longitude=
    alias_method :lng,   :longitude
    alias_method :lng=,  :longitude=
    alias_method :long,  :longitude
    alias_method :long=, :longitude=
  
    def valid?
      return false unless latitude && longitude
      return false unless latitude.abs <= 90 && longitude.abs <= 180
      true
    end
  
    def latitude=(value)
      @latitude = value.to_f
    end

    def longitude=(value)
      @longitude = value.to_f
    end

    def save
      true
    end
  end
end
