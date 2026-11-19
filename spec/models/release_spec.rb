require 'rails_helper'

RSpec.describe Release, type: :model do
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
        expect(described_class.cache_key).to eql "16-03-2023-13-00-#{described_class.last.id}"
      end
    end

    it 'changes for releases with identical timestamps' do
      freeze_time do
        create :release
        previous_key = described_class.cache_key
        latest = create :release

        expect(described_class.cache_key).not_to eq(previous_key)
        expect(described_class.cache_key).to end_with("-#{latest.id}")
      end
    end
  end
end
