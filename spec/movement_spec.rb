require 'spec_helper'

describe Muve::Movement do
  subject { Muve::Movement.new }

  it { is_expected.to respond_to(:traveller) }
  it { is_expected.to respond_to(:location) }
  it { is_expected.to respond_to(:time) }

  shared_examples "a invalid resource" do
    it { is_expected.to be_invalid }
  end

  context "without traveller" do
    subject { build(Muve::Movement, traveller: nil) }
    it_behaves_like "a invalid resource"
  end

  context "without location" do
    subject { build(Muve::Movement, location: nil) }
    it_behaves_like "a invalid resource"
  end

  context "with explicitely set time" do
    let(:time_of_interest) { Time.now - rand(500000) }
    subject { build(Muve::Movement, time: time_of_interest) }
    it { expect(subject.time).to eq(time_of_interest) }
  end

  context "new movement" do
    subject { build(Muve::Movement) }
    it { expect(subject.time).to be_within(2).of(Time.now) }
    it { is_expected.to be_valid }
  end

  it { is_expected.to respond_to(:connection) }

  it 'shares the connection among other models' do
    connection = Object.new
    Muve.init(connection)

    expect(Muve::Model.connection).to eq(connection)

    expect(Muve::Movement.new.connection).to be(connection)
    expect(Muve::Location.new.connection).to be(connection)
    expect(Muve::Traveller.new.connection).to be(connection)
  end
end
