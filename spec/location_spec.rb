require 'spec_helper'

describe Muve::Location do
  let(:latitude) { Faker::Geolocation.lat }
  let(:longitude) { Faker::Geolocation.lng }

  subject { Muve::Location.new(latitude, longitude) }
  it { expect(subject.latitude).to eq(latitude) }
  it { expect(subject.longitude).to eq(longitude) }
  it { expect(subject.lat).to eq(latitude) }
  it { expect(subject.long).to eq(longitude) }
  it { expect(subject.lng).to eq(longitude) }

  let(:new_latitude) { Faker::Geolocation.lat }
  let(:new_longitude) { Faker::Geolocation.lng }
  it { expect { subject.latitude = new_latitude }.to change{subject.latitude}.to(new_latitude) }
  it { expect { subject.lat = new_latitude }.to change{subject.latitude}.to(new_latitude) }
  it { expect { subject.longitude = new_longitude }.to change{subject.longitude}.to(new_longitude) }
  it { expect { subject.long = new_longitude }.to change{subject.longitude}.to(new_longitude) }
  it { expect { subject.lng = new_longitude }.to change{subject.longitude}.to(new_longitude) }

  it 'is invalid when latitude exceeds bounds' do
    expect(Muve::Location.new(-91, longitude)).to be_invalid
    expect(Muve::Location.new( 91, longitude)).to be_invalid
  end

  it 'is invalid when longitude exceeds bounds' do
    expect(Muve::Location.new(latitude, -181)).to be_invalid
    expect(Muve::Location.new(latitude,  181)).to be_invalid
  end
end
