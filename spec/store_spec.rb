describe Muve::Store do
  before do
    class Resource
      include Muve::Model
      with_fields :name

      def self.container
        'resources'
      end
    end

    class GenericStore
      extend Muve::Store
    end

    class GenericFormatter
      extend Muve::Store::Formatter
    end
  end

  it 'provides methods to get a resource' do
    expect(GenericStore).to respond_to(:get)
    expect(GenericStore).to respond_to(:fetch)
  end

  it 'provides methods to create a resource' do
    expect(GenericStore).to respond_to(:create)
  end

  it 'provides methods to destroy a resource' do
    expect(GenericStore).to respond_to(:delete)
    expect(GenericStore).to respond_to(:destroy)
    expect(GenericStore).to respond_to(:remove)
  end

  it 'provides methods to update a resource' do
    expect(GenericStore).to respond_to(:update)
  end

  it 'has a formatter' do
    expect(GenericStore).to respond_to(:formatter)
  end

  it 'raises incomplete implementation errors on non-implemented methods' do
    %w(create delete update fetch find).each do |method|
      expect{
        if method == 'update'
          GenericStore.send(method, 'resource', nil, {})
        else
          GenericStore.send(method, 'resource', nil)
        end
      }.to raise_error(Muve::Error::IncompleteImplementation)
    end

    expect{GenericStore.send(:formatter)}.to raise_error(Muve::Error::IncompleteImplementation)
  end

  it 'attempts to fetch a resource if the id is given' do
    expect(GenericStore).to receive(:fetch)
    GenericStore.get(Resource, SecureRandom.uuid)
  end

  it 'attempts to find a resource if the id is not given but the details are' do
    expect(GenericStore).to receive(:find)
    GenericStore.get(Resource, nil, { name: 'bogus' })
  end

  it 'raises an error if neither id nor details are given' do
    expect{
      GenericStore.get(Resource)
    }.to raise_error
  end

  describe "formatter" do
    it { expect(GenericFormatter).to respond_to(:convert_to_storeable_object) }
    it { expect(GenericFormatter).to respond_to(:convert_from_storeable_object) }
  end
end
