require 'spec_helper'

describe 'Location' do
  before do
    @lat, @lng = Faker::Geolocation.lat, Faker::Geolocation.lng
  end

  it 'knows its latitude and longitude' do
    expect(Location.new(@lat, @lng).latitude).to eq(@lat)
    expect(Location.new(@lat, @lng).longitude).to eq(@lng)
  end

  it 'gets the longitude through its aliases' do
    location = Location.new(@lat, @lng)
    expect(location.lng).to eq(@lng)
  end

  it 'gets the latitude through aliases' do
    location = Location.new(@lat, @lng)
    expect(location.lat).to eq(@lat)
  end

  it 'sets the longitude through its aliases' do
    location = Location.new(@lat, @lng)

    longitude = Faker::Geolocation.lng
    location.lng = longitude
    expect(location.longitude).to eq(longitude)

    longitude = Faker::Geolocation.lng
    location.long = longitude
    expect(location.longitude).to eq(longitude)
  end

  it 'sets the latitude through its aliases' do
    location = Location.new(@lat, @lng)
    latitude = Faker::Geolocation.lat
    location.lat = latitude
    expect(location.latitude).to eq(latitude)
  end

  it 'is invalid when latitude exceeds bounds' do
    expect(Location.new(-181, @lng)).to be_invalid
    expect(Location.new( 181, @lng)).to be_invalid
  end

  it 'is invalid when longitude exceeds bounds' do
    expect(Location.new(@lat, -91)).to be_invalid
    expect(Location.new(@lat,  90)).to be_invalid
  end
end
