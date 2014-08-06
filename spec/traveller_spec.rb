require 'spec_helper'

describe Muve::Traveller do
  subject { Muve::Traveller.new }

  it { is_expected.to respond_to(:id) }
  it { is_expected.to be_invalid }

  context "linked to an existing traveller" do
    subject { Muve::Traveller.new(SecureRandom.uuid) }
    it { is_expected.to be_valid }
  end
end
