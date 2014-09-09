require 'spec_helper'

describe Muve::Place do
  it { expect(Muve::Place.model_name).to eq "Place" }

  it { is_expected.to respond_to :location }
  it { is_expected.to respond_to :name }
end
