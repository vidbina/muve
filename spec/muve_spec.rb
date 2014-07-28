require 'spec_helper'

describe Muve do
  it 'includes the model module' do
    expect{ Muve::Model }.not_to raise_error
  end

  it 'includes the location class' do
    expect{ Muve::Location }.not_to raise_error
  end

  it 'includes the traveller class' do
    expect{ Muve::Traveller }.not_to raise_error
  end

  it 'includes the movement class' do
    expect{ Muve::Movement }.not_to raise_error
  end

  it 'contains a model that behaves like one' do
    class TestModel
      include Muve::Model
    end

    expect(TestModel.new).to respond_to(:save)
    expect(TestModel.new).to respond_to(:valid?)
    expect(TestModel.new).to respond_to(:connection)
  end
end
