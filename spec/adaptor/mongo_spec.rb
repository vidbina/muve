require 'spec_helper'
require 'mongo'

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

    # NOTE: Adaptors return the data and leave the housekeeping of the model
    # up to the respective model itself
    class MongoAdaptor
      extend Muve::Store

      def self.create(resource, details)
        resource.database[resource.container].insert(details)
      end

      def self.fetch(resource, id, details={})
        # TODO: discover a solution that works for situations where database 
        # driver returns string keys as well as symbol keys
        details = {} unless details.kind_of? Hash
        result = resource.database[resource.container].find_one(details.merge(_id: id))
        result = result.merge('id' => result.delete('_id'))
        result
      end

      def self.update(resource, id, details)
        raise MuveInvalidAttributes, "invalid update data" unless details.kind_of? Hash
        # TODO: raise error if details is not valid
        resource.database[resource.container].find_and_modify(
          query: { _id: id },
          update: details
        )
      end

      def self.delete(resource, id, details=nil)
        details = {} unless details.kind_of? Hash
        details = details.merge(_id: id) if id
        resource.database[resource.container].remove(details)
      end
    end

    Muve.init(connection, database)
  end
  
  it 'writes model data to the store' do
    expect{
      MongoAdaptor.create(Place, {
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
      MongoAdaptor.update(Place, id, { name: new_name })
    }.to change{database['places'].find_one(_id: id)['name']}.to(new_name)
  end

  it 'finds resources from store' do
    id = database['places'].insert(name: Faker::Venue.name)
    expect(MongoAdaptor.get(Place, id)["id"]).to eq(id)
  end
end
