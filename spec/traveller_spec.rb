require 'spec_helper'

describe Muve::Traveller do
  it 'has an id' do
    expect(Muve::Traveller.new).to respond_to(:id)
  end

  it 'is invalid without an id' do
    expect(Muve::Traveller.new).to be_invalid
    expect(Muve::Traveller.new(SecureRandom.uuid)).to be_valid
  end
end
