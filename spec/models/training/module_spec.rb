require 'rails_helper'

RSpec.describe Training::Module, type: :model do
  subject(:mod) { described_class.by_name(:alpha) }

  describe '.cache_key' do
    it 'has a default' do
      expect(described_class.cache_key).to eql 'initial'
    end
  end

  describe '.by_name' do
    it 'loads linked entries' do
      expect(mod.pages).to be_present
    end
  end

  describe '#content' do
    it 'does not include interruption the page' do
      expect(mod.content.map(&:page_type)).not_to include 'interruption_page'
    end
  end

  describe 'attributes' do
    it '#title' do
      expect(mod.title).to eq 'First Training Module'
    end
  end

  describe '#answers_with' do
    it 'case-insensitive search of Question JSON field' do
      expect(mod.answers_with('foo')).to eq [] # no match
      # expect(mod.answers_with('')).to eq [] # formative
      expect(mod.answers_with('Wrong\s.+ 3')).to eq %w[1-3-2-4 1-3-2-5 1-3-2-6 1-3-2-7 1-3-2-8 1-3-2-9 1-3-2-10] # summative
      expect(mod.answers_with('NOR')).to eq %w[1-3-3-1 1-3-3-2 1-3-3-3 1-3-3-4] # confidence
    end
  end

  describe '#content_sections' do
    let(:sections) { mod.content_sections }

    it 'returns sections' do
      expect(sections).to be_a Hash
      expect(sections.keys).to eq [1, 2, 3, 4, 5]
      expect(sections.values.map(&:count)).to eq [7, 5, 19, 7, 1]
    end
  end

  describe '#content_subsections' do
    let(:subsections) { mod.content_subsections }

    it 'returns subsections' do
      expect(subsections).to be_a Hash
      expect(subsections.keys).to eq [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [2, 0], [2, 1], [3, 0], [3, 1], [3, 2], [3, 3], [4, 0], [5, 0]]
      expect(subsections.values.map(&:count)).to eq [1, 1, 1, 2, 2, 1, 4, 1, 1, 12, 5, 7, 1]
    end
  end

  describe '#submodule_count' do
    it 'returns the number of sections' do
      expect(mod.submodule_count).to eq 5
    end
  end

  describe '#topic_count' do
    it 'returns the number of subsections' do
      expect(mod.topic_count).to eq 8 # 4, 1, 3
    end
  end

  describe '#first_published_at' do
    include_context 'with module releases'

    it 'returns the first published date' do
      expect(mod.first_published_at).to be_within(1.second).of 2.days.ago
    end
  end
end
