require 'rails_helper'

RSpec.describe Release, :cms, type: :model do
  describe '.cache_key' do
    context 'with no releases' do
      it 'is nil' do
        expect(described_class.cache_key).to be_nil
      end
    end

    context 'with releases' do
      before do
        described_class.create!(name: 'release1', time: '2023-03-16 13:00:00')
        described_class.create!(name: 'release2', time: '2023-03-16 12:00:00')
      end

      it 'is latest formatted timestamp' do
        expect(described_class.cache_key).to eql '16-03-2023-13-00'
      end
    end
  end
end
