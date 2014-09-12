require 'spec_helper'

describe Muve::Place do
  it { expect(Muve::Place.model_name).to eq "Place" }

  it { is_expected.to respond_to :location }
  it { is_expected.to respond_to :name }

  it 'is invalid when the location is not a Location' do
    expect(build Muve::Place, location: Object.new).to be_invalid
    expect(build Muve::Place, location: rand).to be_invalid
    expect(build Muve::Place, location: build(Muve::Location, latitude: -100)).to be_invalid
    expect(build Muve::Place, location: build(Muve::Location)).to be_valid
  end
end
