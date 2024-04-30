require 'rails_helper'

RSpec.describe Caching do
  let(:described_class) { Training::Module }

  describe '.cache_key' do
    before do
      described_class.reset_cache_key!
    end

    it 'has a default' do
      expect(Release.all.count).to be 0
      expect(Release.cache_key).to be_nil
      expect(described_class.cache_key).to eql 'initial'
    end
  end

  describe '.reset_cache_key!' do
    it 'recalculates the timestamp for the newest release' do
      expect(Release.all.count).to be 0
      expect(Release.cache_key).to be_nil
      expect(described_class.cache_key).to eq 'initial'

      create :release, time: '2023-03-16 13:00:00'
      expect(described_class.cache_key).to eq 'initial'

      described_class.reset_cache_key!
      expect(described_class.cache_key).to eq '16-03-2023-13-00'

      create :release, time: '2023-04-01 12:00:00'
      described_class.reset_cache_key!
      expect(described_class.cache_key).to eq '01-04-2023-12-00'
    end
  end
end
