require 'rails_helper'

RSpec.describe Caching do
  describe '#reset_cache_key!' do
    it 'rotates in cache' do
      expect(Training::Module.cache_key).to eq 'initial'
      Release.create!(name: 'release1', time: '2023-03-16 13:00:00')
      expect(Training::Module.cache_key).to eq 'initial'

      Training::Module.reset_cache_key!
      expect(Training::Module.cache_key).to eq '16-03-2023-13-00'

      Release.create!(name: 'release2', time: '2023-04-01 12:00:00')
      Training::Module.reset_cache_key!
      expect(Training::Module.cache_key).to eq '01-04-2023-12-00'
    end
  end
end
