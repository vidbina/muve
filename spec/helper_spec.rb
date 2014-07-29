describe Muve::Helper do
  describe '#symbolize_keys' do
    it 'converts all keys to symbols' do
      hash = { 'name' => 'Stewie Griffin', :skill => 'Physics' }
      expect(Muve::Helper.symbolize_keys(hash)).to eq(
        name: 'Stewie Griffin', 
        skill: 'Physics'
      )
    end
  end
end
