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

  it 'is invalid when the name is not specified' do
    expect(build Muve::Place, name: nil).to be_invalid
  end

  it 'is invalid when the location is invalid' do
    expect(build Muve::Place, location: build(Muve::Location, :invalid)).to be_invalid
  end

  it 'is valid when all field are set' do
    expect(build Muve::Place).to be_valid
  end
end
