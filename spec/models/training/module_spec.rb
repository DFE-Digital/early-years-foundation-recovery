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

  describe '#content_by_submodule' do
    let(:sections) { mod.content_by_submodule }

    it 'returns sections' do
      expect(sections).to be_a Hash
      expect(sections.keys).to eq [1, 2, 3]
      expect(sections.values.map(&:count)).to eq [7, 5, 21]
    end
  end

  describe '#content_by_submodule_topic' do
    let(:subsections) { mod.content_by_submodule_topic }

    it 'returns subsections' do
      expect(subsections).to be_a Hash
      expect(subsections.keys).to eq [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [2, 0], [2, 1], [3, 0], [3, 1], [3, 2], [3, 3], [3, 4]]
      expect(subsections.values.map(&:count)).to eq [1, 1, 1, 2, 2, 1, 4, 1, 1, 12, 6, 1]
    end
  end

  describe '#submodule_count' do
    it 'returns the number of sections' do
      expect(mod.submodule_count).to eq 3
    end
  end

  describe '#topic_count' do
    it 'returns the number of subsections' do
      expect(mod.topic_count).to eq 9 # 4, 1, 4
    end
  end
end
