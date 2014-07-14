class Location
  attr_accessor :latitude, :longitude
  alias_method :lat, :latitude
  alias_method :lat=, :latitude=
  alias_method :lng, :longitude
  alias_method :lng=, :longitude=

  def initialize(latitude, longitude, type=:wgs84)
    @latitude, @longitude = latitude, longitude
  end

  def valid?
    return false unless latitude.abs <= 90 && longitude.abs <= 180
  end

  def invalid?
    !valid?
  end

  def random(center, range)
  end
end
