require 'spec_helper'

describe Movement do
  it 'knows a location and a traveller and possibly a time' do
    expect(Movement.new).to respond_to(:traveller)
    expect(Movement.new).to respond_to(:location)
    expect(Movement.new).to respond_to(:time)
  end

  it 'is invalid without a traveller' do
    expect(build(:movement, traveller: nil)).to be_invalid
  end

  it 'is invalid without a location' do
    expect(build(:movement, location: nil)).to be_invalid
  end

  it 'assumes the current time unless specified' do
    expect(build(:movement).time).to be_within(2).of(Time.now)
  end

  it 'is valid with a traveller and location' do
    expect(build(:movement)).to be_valid
  end
end
