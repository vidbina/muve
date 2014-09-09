module Muve
  class Movement
    include Model
  
    with_fields :traveller, :location, :time

    def latitude
      location[:latitude] if location
    end

    def longitude
      location[:longitude] if location
    end

    def latitude=(value)
      location = {} unless location
      location[:latitude]=(value) 
    end

    def longitude=(value)
      location = {} unless location
      location[:longitude]=(value) 
    end

    def valid?
      assocs.each do |assoc|
        return false unless !assoc.nil? && assoc.valid?
      end
      fields.each do |field|
        return false unless time
      end
      true
    end
  
    alias_method :lat,   :latitude
    alias_method :lat=,  :latitude=
    alias_method :lon,   :longitude
    alias_method :lon=,  :longitude=
    alias_method :lng,   :longitude
    alias_method :lng=,  :longitude=
    alias_method :long,  :longitude
    alias_method :long=, :longitude=
  
    private
    def assocs
      [
        @traveller,
        @location
      ]
    end
  end
end
