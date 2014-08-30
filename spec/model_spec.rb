describe 'Model' do
  before(:each) do
    class Resource
      include Muve::Model
      with_fields :name, :version, :another

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

    class SomeAdaptor
      extend Muve::Store

      def self.index_hash(index_value)
        { :_id => index_value }
      end
    end

    class AnotherAdaptor
      extend Muve::Store

      def self.index_hash(index_value)
        { :_id => index_value }
      end
    end

    Resource.remove_instance_variable(:@handler) if Resource.instance_variable_defined?(:@handler)
    AnotherResource.remove_instance_variable(:@handler) if AnotherResource.instance_variable_defined?(:@handler)

    Muve::Model.init SomeAdaptor
  end

  context 'AnotherResource' do
    subject { AnotherResource }
    it { is_expected.to respond_to(:extract_attributes) }
    it { expect(subject.send(:extract_attributes,
      resource: subject.new(
        name: 'Stewie Griffin',
        version: 'our instance of the multiverse',
        description: 'Evil baby with a lot of heart',
        age: 1
      ),
      fields: subject.new.send(:fields),
      invalid_attributes: subject.new.send(:invalid_attributes),
      id: SecureRandom.hex
    )).to include :name, :version, :description, :age }
  end

  context 'Resource' do
    before(:each) {
      Muve::Model.init(SomeAdaptor)
    }

    subject { Resource }
    it { is_expected.to respond_to(:extract_attributes) }
    it { expect(subject.send(:extract_attributes,
      resource: subject.new(
        name: 'Stewie Griffin',
        version: 'our instance of the multiverse',
        another: AnotherResource.new
      ),
      fields: subject.new.send(:fields),
      invalid_attributes: subject.new.send(:invalid_attributes),
      id: SecureRandom.hex
    )).to include :name, :version, :another }
  end

  context 'Resource' do
    subject { Resource }
    it { is_expected.to respond_to(:extract_attributes) }
    it { expect(subject.send(:extract_attributes,
      resource: subject.new(
        name: 'Stewie Griffin',
        version: 'our instance of the multiverse',
        another: AnotherResource.new
      ),
      fields: subject.new.send(:fields),
      invalid_attributes: subject.new.send(:invalid_attributes),
      id: SecureRandom.hex
    )).to include(:name, :version, :another) }

    it { 
      expect(subject.new(
      name: 'Stewie Griffin',
      version: 'our instance of the multiverse',
      another: subject.new(
        name: 'Bitch Stewie',
        version: 'failed experiment',
        another: subject.new(
          name: 'Bitch-Brian',
          version: 'failed clone by failed experiment'
        )
      )
    ).send(:serialized_attributes)).to eq(
      name: 'Stewie Griffin',
      version: 'our instance of the multiverse',
      another: {
        name: 'Bitch Stewie',
        version: 'failed experiment'
      }
    ) }

    it { expect(subject.new(
      name: 'Stewie Griffin',
      version: 'our instance of the multiverse',
      another: subject.new(
        name: 'Bitch Stewie',
        version: 'failed experiment',
        another: subject.new(
          name: 'Bitch-Brian',
          version: 'failed clone by failed experiment'
        )
      )
    ).send(:serialized_attributes)).to eq(
      name: 'Stewie Griffin',
      version: 'our instance of the multiverse',
      another: {
        name: 'Bitch Stewie',
        version: 'failed experiment'
      }
    ) }
  end

  context "instantiated AnotherResource" do
    subject { AnotherResource.new }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:to_hash) }
    it { is_expected.to respond_to(:version) }
    it { is_expected.to respond_to(:valid?) }
    it { expect(subject.send(:fields)).to include :name, :version, :description, :age }
    it { expect(subject.send(:attributes)).to include :name, :version, :description, :age }

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
        it { expect(subject.attributes).to eq({ name: 'Peter Griffin', description: 'Surfin-bird lover', version: 'the fat one', age: nil }) }
      end
    end
  end

  it 'remembers its connection' do
    object = Object.new
    Muve::Model.connection = object
    expect(Muve::Model.connection).to be(object)
  end

  it 'raises a not configured exception when connection is not set' do
    configuration_error = Muve::Error::NotConfigured
    Muve::Model.remove_class_variable(:@@conn) if Muve::Model.class_variable_defined?(:@@conn)

    expect { Muve::Model.connection }.to raise_error(configuration_error)
    expect { Resource.connection }.to raise_error(configuration_error) 
    expect { AnotherResource.connection }.to raise_error(configuration_error)
  end

  it 'raises a not configured exception when database is not set' do
    configuration_error = Muve::Error::NotConfigured
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
    Resource.adaptor = SomeAdaptor
    expect(Resource.adaptor).to be(SomeAdaptor)
  end

  it 'allows different adaptors for different resources' do
    Resource.adaptor = SomeAdaptor
    AnotherResource.adaptor = AnotherAdaptor

    expect(Resource.adaptor).to be(SomeAdaptor)
    expect(AnotherResource.adaptor).to be(AnotherAdaptor)
  end

  it 'allows the setting of the adaptor through init' do
    Muve::Model.init(adaptor = SomeAdaptor)
    expect(Resource::adaptor).to be(SomeAdaptor)
    expect(Resource.adaptor).to be(SomeAdaptor)
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

  it 'allows the modification of attributes' do
    resource = Resource.new(name: 'muve-resource', version: 0)
    expect(resource.name).to eq('muve-resource')
    expect(resource.version).to eq(0)

    resource.attributes = { name: 'french', version: 1 }
    expect(resource.name).to eq('french')
    expect(resource.version).to eq(1)
  end

  # TODO: Study if this is desirable perhaps one would rather prefer setting
  # seperate adaptors for different models
  it 'shares the adaptor amongst all its instances' do
    Resource.remove_instance_variable(:@adaptor) if Resource.instance_variable_defined?(:@adaptor)
    AnotherResource.remove_instance_variable(:@adaptor) if AnotherResource.instance_variable_defined?(:@adaptor)

    Muve::Model.init(SomeAdaptor)
    expect(Muve::Model.send(:handler)).to be(SomeAdaptor)
    expect(Resource.new.send(:adaptor)).to be(SomeAdaptor)
    expect(AnotherResource.new.send(:adaptor)).to be(SomeAdaptor)

    Muve::Model.init(AnotherAdaptor)
    expect(Muve::Model.send(:handler)).to be(AnotherAdaptor)
    expect(Resource.new.send(:adaptor)).to be(AnotherAdaptor)
    expect(AnotherResource.new.send(:adaptor)).to be(AnotherAdaptor)
  end

  it 'allows different adaptors for different entities' do
    Resource.remove_instance_variable(:@adaptor) if Resource.instance_variable_defined?(:@adaptor)
    AnotherResource.remove_instance_variable(:@adaptor) if AnotherResource.instance_variable_defined?(:@adaptor)
    
    a = SomeAdaptor
    b = AnotherAdaptor

    Muve::Model.init(a)
    Resource.adaptor = b
    expect(Resource.new.send(:adaptor)).to be(b)
    expect(AnotherResource.new.send(:adaptor)).to be(a)
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

        def self.index_hash(index_value)
          hash = { :_id => index_value }
          { :_id => index_value }
        end
      end

      Resource.adaptor = GenericAdaptor
      AnotherResource.adaptor = GenericAdaptor # FIX: allow setting system-wide adaptor?

      @res = Resource.new
    end

    shared_examples "an ActiveRecord-like class" do
      it { is_expected.to respond_to(:create) }
      it { is_expected.to respond_to(:destroy_all) }
      it { is_expected.to respond_to(:find) }
    end

    shared_examples "an ActiveRecord-like resource" do
      it { is_expected.to respond_to(:save) }
      it { is_expected.to respond_to(:destroy) }
      it { is_expected.to respond_to(:new_record?) }
      it { is_expected.to respond_to(:destroyed?) }
    end
  
    context "the class" do
      subject { Resource }
      it_behaves_like "an ActiveRecord-like class"
    end

    context "a instance" do
      subject { @res }
      it_behaves_like "an ActiveRecord-like resource"
    end

    it 'calls the store create handler upon save' do
      expect(GenericAdaptor).to receive(:create).once
      @res.save
    end

    describe '#reload' do
      it 'does' do
        id = SecureRandom.hex
        initial_attrs = {
          id: id,
          name: 'First',
          version: '0',
          description: 'before'
        }
        final_attrs = {
          id: id,
          name: 'Last',
          version: '99',
          description: 'after'
        }
        allow(GenericAdaptor).to receive(:fetch).and_return(initial_attrs)
        resource = AnotherResource.find(id)
        expect(resource.attributes).to include(initial_attrs)

        allow(GenericAdaptor).to receive(:fetch).and_return(final_attrs)
        expect(resource.attributes).to include(initial_attrs)
        expect(resource.reload.attributes).to include(final_attrs)
      end
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

    describe '::create' do
      before(:each) do
        allow(GenericAdaptor).to receive(:create).and_return(@id = SecureRandom.hex)
      end

      it 'creates a new instance' do
        attributes = { name: 'Bonobo' }
        expect(Resource).to receive(:new).with(attributes).and_return(Resource.new(attributes)).once
        expect(Resource.create(attributes)).to be_a(Resource)
      end

      it 'calls the save handler' do
        expect_any_instance_of(Resource).to receive(:save).once
        Resource.create(name: 'Nice')
      end

      it 'has the set attributes' do
        resource = Resource.create(name: 'Monaco')
        expect(resource.name).to eq('Monaco')
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
        expect(GenericAdaptor).to receive(:delete).with(AnotherResource, @id).once
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

    it 'converts the attributes to saveable objects' do
      expect(Resource.new(
        name: 'Peter Griffin',
        version: 'dumbass',
        another: AnotherResource.new(
          name: 'Brian Griffin',
          version: 'the pretentious one',
          description: 'Canine, liberal, writer',
          age: 8
        )
      ).send(:to_hash)).to eq(
        name: 'Peter Griffin',
        version: 'dumbass',
        another: {
          name: 'Brian Griffin',
          version: 'the pretentious one',
          description: 'Canine, liberal, writer',
          age: 8
        }
      )
    end

    it 'converts the attributes to saveable objects' do
      another = AnotherResource.new
      another.send :populate, {
        id: SecureRandom.hex,
        name: 'Brian Griffin',
        version: 'the pretentious one',
        description: 'Canine, liberal, writer',
        age: 8
      }
      expect(Resource.new(
        name: 'Peter Griffin', 
        version: 'dumbass', 
        another: another
      ).send(:to_hash)).to eq(
        name: 'Peter Griffin',
        version: 'dumbass',
        another: {
          id: another.id,
          name: 'Brian Griffin',
          version: 'the pretentious one',
          description: 'Canine, liberal, writer',
          age: 8
        }
      )
    end

    it 'returns the attributes on request' do
      another = AnotherResource.new
      another.send :populate, {
        id: SecureRandom.hex,
        name: 'Brian Griffin',
        version: 'the pretentious one',
        description: 'Canine, liberal, writer',
        age: 8
      }
      resource = Resource.new
      id = SecureRandom.hex
      resource.send :populate, {
        id: id,
        name: 'Peter Griffin', 
        version: 'dumbass', 
        another: another
      }

      expect(resource.attributes).to eq(
        id: id,
        name: 'Peter Griffin',
        version: 'dumbass',
        another: another
      )
    end
    
    it 'converts repopulated data to resources' do
      data = {
        id: SecureRandom.hex,
        name: 'Peter Griffin',
        version: 'dumbass',
        another: {
          id: SecureRandom.hex,
          name: 'Brian Griffin',
          version: 'the pretentious one',
          description: 'Canine, liberal, writer',
          age: 8
        }
      }
      resource = Resource.new
      resource.send(:populate, data)
    end
  end

  describe ".to_param" do
    it "is equal to the stringified id" do
      object = AnotherResource.new
      object.send :populate, {
        id: SecureRandom.hex,
        name: 'Brian Griffin',
        version: 'the pretentious one',
        description: 'Canine, liberal, writer',
        age: 8
      }
      expect(object.id.to_s).to eq(object.to_param)
    end
  end
end
