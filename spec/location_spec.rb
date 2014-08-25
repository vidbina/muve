require 'spec_helper'

describe Muve::Location do
  let(:latitude) { Faker::Geolocation.lat }
  let(:longitude) { Faker::Geolocation.lng }

  subject { Muve::Location.new latitude: latitude, longitude: longitude }
  it { expect(subject.latitude).to eq(latitude) }
  it { expect(subject.longitude).to eq(longitude) }
  it { expect(subject.lat).to eq(latitude) }
  it { expect(subject.long).to eq(longitude) }
  it { expect(subject.lng).to eq(longitude) }

  it { is_expected.to respond_to(:lat) }
  it { is_expected.to respond_to(:latitude) }

  it { is_expected.to respond_to(:lat=) }
  it { is_expected.to respond_to(:latitude=) }

  it { is_expected.to respond_to(:lon) }
  it { is_expected.to respond_to(:long) }
  it { is_expected.to respond_to(:longitude) }

  it { is_expected.to respond_to(:lon=) }
  it { is_expected.to respond_to(:long=) }
  it { is_expected.to respond_to(:longitude=) }

  let(:new_latitude) { Faker::Geolocation.lat }
  let(:new_longitude) { Faker::Geolocation.lng }
  # FIX: sometimes the new_* returns the same value as the already set value which fails when pulled through the change matcher
  it { expect { subject.latitude = new_latitude }.to(change{subject.latitude}.to(new_latitude), "expected #{subject.latitude} to be #{new_latitude}") }
  it { expect { subject.lat = new_latitude }.to change{subject.latitude}.to(new_latitude) }
  it { expect { subject.longitude = new_longitude }.to change{subject.longitude}.to(new_longitude) }
  it { expect { subject.long = new_longitude }.to change{subject.longitude}.to(new_longitude) }
  it { expect { subject.lng = new_longitude }.to change{subject.longitude}.to(new_longitude) }

  it 'is invalid when latitude exceeds bounds' do
    expect(build Muve::Location, latitude: -91).to be_invalid
    expect(build Muve::Location, latitude:  91).to be_invalid
  end

  it 'is invalid when longitude exceeds bounds' do
    expect(build Muve::Location, longitude: -181).to be_invalid
    expect(build Muve::Location, longitude:  181).to be_invalid
  end

  context "validation" do
    before(:each) { allow_any_instance_of(Muve::Location).to receive(:create_or_update).and_return(true) }
    it { expect{build(Muve::Location, longitude: -181).save}.to raise_error }
    it { expect{build(Muve::Location).save}.not_to raise_error }
  end
end
