require 'spec_helper'

describe 'Mongo Adaptor' do
  let(:connection) { Mongo::MongoClient.new }
  let(:database) { connection.db('muve_test') }
  before do
    class Place
      include Muve::Model

      def self.container
        'places'
      end
    end

    Muve.init(connection, database)
  end
  
  it 'writes model data to the store' do
    expect{
      Muve::Store::Mongo.create(Place, {
        city: Faker::Address.city,
        street: Faker::Address.street_name,
        building: Faker::Address.building_number
      })
    }.to change{database['places'].count}.by(1)
  end

  it 'writes modifications to the store' do
    id = database['places'].insert(name: Faker::Venue.name)
    new_name = Faker::Venue.name

    expect{
      Muve::Store::Mongo.update(Place, id, { name: new_name })
    }.to change{database['places'].find_one(_id: id)['name']}.to(new_name)
  end

  it 'finds a resource from store' do
    id = database['places'].insert(name: Faker::Venue.name)
    expect(Muve::Store::Mongo.get(Place, id)[:id]).to eq(id)
  end

  it 'finds multiple resources from store' do
    expect(Muve::Store::Mongo.find(Place, {})).to be_a(Enumerable)
  end

  it 'extracts a resource from every result in a multiple resource set' do
    Muve::Store::Mongo.find(Place, {}).take(3).each do |result|
      attributes = result.keys.map{ |i| i.to_s }
      expect(attributes).to include('id', 'city', 'street', 'building')
    end
  end
end
