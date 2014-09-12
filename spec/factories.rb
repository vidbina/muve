FactoryGirl.define do
  factory Muve::Location do
    lat { Faker::Geolocation.lat }
    long { Faker::Geolocation.lng }

    trait :invalid do
      lat { 200 }
      long { 200 }
    end
  end

  factory Muve::Traveller do
    name { Faker::Name.name }

    trait :invalid do
      name { nil }
    end
  end

  factory Muve::Movement do
    traveller { build Muve::Traveller }
    location { build Muve::Location }
    time { Time.now - rand(500000) }

    trait :invalid do
      location { build Muve::Location, :invalid }
    end
  end

  factory Muve::Place do
    name { Faker::Venue.name }
    location { build Muve::Location }

    trait :invalid do
      location { build Muve::Location, :invalid }
    end
  end
end
