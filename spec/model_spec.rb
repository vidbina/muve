describe Muve::Model do
  before do
    class Resource
      include Muve::Model
      attr_accessor :name, :version
    end

    class AnotherResource
      include Muve::Model
      attr_accessor :name, :version, :description
    end
  end

  it 'allows the setting of the adaptor' do
    adaptor = Object.new
    Resource.adaptor = adaptor
    expect(Resource.adaptor).to be(adaptor)
  end

  it 'allows the setting of the adaptor through init' do
    adaptor = Object.new
    Muve::Model.init(adaptor = adaptor)
    expect(Muve::Model::handler).to be(adaptor)
    expect(Muve::Model.handler).to be(adaptor)
  end

  it 'sets the attributes of the resource at initialization' do
    resource = Resource.new(name: 'muve-resource', version: 0)
    expect(resource.name).to eq('muve-resource')
    expect(resource.version).to eq(0)

    another = AnotherResource.new(name: 'muve-something', version: nil, description: 'blah')
    expect(another.name).to eq('muve-something')
    expect(another.version).to eq(nil)
    expect(another.description).to eq('blah')
  end

  # TODO: Study if this is desirable perhaps one would rather prefer setting
  # seperate adaptors for different models
  it 'shares the adaptor amongst all its instances' do
    generic_adaptor = Object.new
    Resource.adaptor = generic_adaptor

    3.times {
      expect(Resource.new.send(:adaptor)).to be(generic_adaptor)
    }

    3.times {
      expect(AnotherResource.new.send(:adaptor)).to be(generic_adaptor)
    }
  end

  describe 'equiped with an adaptor' do
    before do
      class Resource
        include Muve::Model

        def valid?
          true
        end

        def set_as_new_record(bool)
          @new_record = bool
        end
      end

      class GenericAdaptor
        extend Muve::Store
      end

      Resource.adaptor = GenericAdaptor

      @res = Resource.new
    end

    it 'calls the store create handler upon save' do
      expect(GenericAdaptor).to receive(:create).once
      @res.save
    end

    it 'calls the delete handler upon remove' do
      expect(GenericAdaptor).to receive(:delete).once
      @res.destroy
    end

    it 'calls the update handler upon save on a resource with an id' do
      id = SecureRandom.uuid
      expect(GenericAdaptor).to receive(:update).once
      @res.set_as_new_record false
      expect(@res.new_record?).to be(false)
      @res.save
    end

    it 'calls the find handler upon a request to find resources' do
      expect(GenericAdaptor).to receive(:find).with(Resource, { name: 'bogus' })
      Resource.where(name: 'bogus')
    end

    it 'calls the fetcher to get a resource' do
      id = SecureRandom.uuid
      expect(GenericAdaptor).to receive(:fetch).with(Resource, id, nil)
      Resource.find(id)
    end
  end
end
