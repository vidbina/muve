describe 'Model' do
  before do
    class Resource
      include Muve::Model
      with_fields :name, :version

      def self.container
        'resources'
      end
    end

    class AnotherResource
      include Muve::Model
      with_fields :name, :version, :description, :age

      def self.container
        'other_resources'
      end
    end
  end

  context "instantiated AnotherResource" do
    subject { AnotherResource.new }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:version) }
    it { is_expected.to respond_to(:valid?) }
    it { expect(subject.send(:fields)).to include :name, :version, :description, :age }

    context "populating" do
      context "with nothing" do
        before { subject.send(:populate, {}) }
        it { expect(subject.name).to eq(nil) }
      end
  
      context "with unknown fields" do
        before { subject.send(:populate, { name: 'Jack Sparrow', occupation: 'pirate' }) }
        it { expect(subject.name).to eq('Jack Sparrow') }
        it { expect{ subject.occupation }.to raise_error }
      end
  
      context "with known fields" do
        before { subject.send(:populate, { name: 'Peter Griffin', description: 'Surfin-bird lover', version: 'the fat one' }) }
        it { expect(subject.name).to eq('Peter Griffin') }
        it { expect(subject.description).to eq('Surfin-bird lover') }
        it { expect(subject.version).to eq('the fat one') }
      end
    end
  end

  it 'remembers its connection' do
    object = Object.new
    Muve::Model.connection = object
    expect(Muve::Model.connection).to be(object)
  end

  it 'raises a not configured exception when connection is not set' do
    configuration_error = MuveError::MuveNotConfigured
    Muve::Model.remove_class_variable(:@@conn) if Muve::Model.class_variable_defined?(:@@conn)

    expect { Muve::Model.connection }.to raise_error(configuration_error)
    expect { Resource.connection }.to raise_error(configuration_error) 
    expect { AnotherResource.connection }.to raise_error(configuration_error)
  end

  it 'raises a not configured exception when database is not set' do
    configuration_error = MuveError::MuveNotConfigured
    Muve::Model.remove_class_variable(:@@db) if Muve::Model.class_variable_defined?(:@@db)

    expect { Muve::Model.database }.to raise_error(configuration_error)
    expect { Resource.database }.to raise_error(configuration_error) 
    expect { AnotherResource.database }.to raise_error(configuration_error)
  end

  it 'knows the identifier of its repository' do
    expect(Resource).to respond_to(:container)
    expect(Resource.container).to eq('resources')
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

    expect(Resource.new.send(:adaptor)).to be(generic_adaptor)
    expect(AnotherResource.new.send(:adaptor)).to be(generic_adaptor)
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

    describe '#find' do
      before(:each) do
        @id = SecureRandom.hex
        allow(GenericAdaptor).to receive(:fetch).and_return({ 
          id: @id, 
          name: 'Smile',
          version: '0',
          description: 'Supermodel smile... at least that is what they said'
        })
        allow(GenericAdaptor).to receive(:find).and_return(Enumerator.new { |y|
          5.times {
            y << { id: 12, name: 'Something', version: 1, description: 'haha' }
          }
        })
      end

      it 'returns an instance of the model' do
        expect(AnotherResource.find(@id)).to be_a(AnotherResource)
      end

      it 'returns an object containing the record data' do
        result = AnotherResource.find(@id)
        expect(result.name).to eq('Smile')
      end

      it 'returns a record that is not a new record' do
        expect(AnotherResource.find(@id).new_record?).to be(false)
      end
    end

    describe '#where' do
      before(:each) do
        allow(GenericAdaptor).to receive(:find).and_return(Enumerator.new { |y|
          5.times {
            y << { id: 12, name: 'Something', version: 1, description: 'ahha' }
          }
        })
      end

      it 'returns the complete result set' do
        expect(AnotherResource.where({ name: 'all' }).count).to eq(5)
      end

      it 'returns a instance of the resource for each item' do
        AnotherResource.where({ name: 'all' }).each do |item|
          expect(item).to be_a(AnotherResource)
        end
      end
    end

    describe '#save' do
      before(:each) do
        @res.name = 'first'
        allow(GenericAdaptor).to receive(:create).and_return(@id = SecureRandom.hex)
      end

      describe 'on a new record' do
        it 'returns an instance of itself' do
          expect(@res.save).to be_a(Resource)
        end
  
        it 'obtains an id' do
          expect { @res.save }.to change{ @res.id }.to(@id)
        end
  
        it 'is no longer a new record' do
          expect{ @res.save }.to change{ @res.new_record? }.to(false)
        end
  
        it 'is persisted' do
          expect{ @res.save }.to change{ @res.persisted? }.to(true)
        end
      end

      describe 'on a existing record' do
        before(:each) do
          allow(GenericAdaptor).to receive(:update).and_return(true)
          @res.save
        end
  
        it 'returns persist the resource' do
          expect(@res).to receive(:update).once
          @res.name = 'second'
          @res.save
        end
      end
    end

    describe '#destroy' do
      before(:each) do
        @id = SecureRandom.hex
        allow(GenericAdaptor).to receive(:fetch).and_return({ 
          id: @id, 
          name: 'Laugh',
          version: 28,
          description: 'The best laugh ever... makes me laugh'
        })
        allow(GenericAdaptor).to receive(:delete).and_return(true)
        @res = AnotherResource.find(@id)
      end

      it 'is marked as removed' do
        expect { @res.destroy }.to change{ @res.destroyed? }.to(true)
      end

      it 'is not a new record' do
        expect { @res.destroy }.to change{ @res.destroyed? }.to(true)
      end
  
      it 'calls the delete handler upon remove' do
        expect(GenericAdaptor).to receive(:delete).once
        @res.destroy
      end
  
      it 'calls the delete handler with the proper details' do
        expect(GenericAdaptor).to receive(:delete).with('other_resources', @id).once
        @res.destroy
      end
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
      Resource.where(name: 'bogus').take(1)
    end

    it 'calls the fetcher to get a resource' do
      id = SecureRandom.uuid
      expect(GenericAdaptor).to receive(:fetch).with(Resource, id, anything)
      Resource.find(id)
    end
  end
end
