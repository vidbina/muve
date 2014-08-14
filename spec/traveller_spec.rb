require 'spec_helper'

describe Muve::Traveller do
  subject { build Muve::Traveller }

  it { is_expected.to respond_to(:id) }
  it { is_expected.to be_valid }

  context "linked to an existing traveller" do
    subject { 
      res = build Muve::Traveller
      res.send(:populate, ({ id: SecureRandom.uuid })) 
      res
    }

    it { is_expected.to be_valid }
  end

  it 'is invalid if the traveller is nameless' do
    expect(build Muve::Traveller, name: nil).to be_invalid
  end
end
