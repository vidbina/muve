FactoryGirl.define do
  factory Muve::Location do
    lat { Faker::Geolocation.lat }
    long { Faker::Geolocation.lng }
  end

  factory Muve::Traveller do
    id { SecureRandom.uuid }
  end

  factory Muve::Movement do
    traveller { build(Muve::Traveller) }
    #traveller_id { SecureRandom.uuid }
    location { build(Muve::Location) }
  end
end
