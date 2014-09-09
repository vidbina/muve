FactoryGirl.define do
  factory Muve::Location do
    lat { Faker::Geolocation.lat }
    long { Faker::Geolocation.lng }
  end

  factory Muve::Traveller do
    name { Faker::Name.name }
  end

  factory Muve::Movement do
    traveller { build Muve::Traveller }
    location { build Muve::Location }
    time { Time.now - rand(500000) }
  end

  factory Muve::Place do
    name { Faker::Venue.name }
    location { build Muve::Location }
  end
end
