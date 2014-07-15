require 'spec_helper'

describe Traveller do
  it 'has an id' do
    expect(Traveller.new).to respond_to(:id)
  end

  it 'is invalid without an id' do
    expect(Traveller.new).to be_invalid
    expect(Traveller.new(SecureRandom.uuid)).to be_valid
  end
end
