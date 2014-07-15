FactoryGirl.define do
  factory :location do
    lat { Faker::Geolocation.lat }
    long { Faker::Geolocation.lng }
  end

  factory :traveller do
    id { SecureRandom.uuid }
  end

  factory :movement do
    traveller { build(:traveller) }
    #traveller_id { SecureRandom.uuid }
    location { build(:location) }
  end
end
