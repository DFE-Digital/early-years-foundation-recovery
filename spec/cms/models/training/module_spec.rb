require 'rails_helper'

RSpec.describe Training::Module, :cms, type: :model do
  subject(:mod) { described_class.by_name(:alpha) }

  before do
    skip 'CMS ONLY' unless Rails.application.cms?
  end

  describe '.cache_key' do
    it 'has a default' do
      expect(described_class.cache_key).to eql 'initial'
    end
  end

  describe '.by_name' do
    it 'does not load linked entries' do
      expect(mod.pages).to be_empty
    end
  end

  describe 'attributes' do
    it '#title' do
      expect(mod.title).to eq 'First Training Module'
    end
  end

  describe '#answers_with' do
    it 'case-insensitive search of Question JSON field' do
      expect(mod.answers_with('NOR')).to eq %w[1-3-3-1 1-3-3-2 1-3-3-3] # confidence questions
      expect(mod.answers_with('foo')).to eq []
      expect(mod.answers_with('Wrong\s.+ 3')).to eq %w[1-3-2-4]
    end
  end

  describe 'YAML conversion' do
    let(:attributes) { TrainingModule.first.cms_module_params }

    it 'migrates fields' do
      expect(attributes.keys.sort).to eql(%i[
        criteria
        description
        duration
        name
        objective
        position
        short_description
        summative_threshold
        title
      ])
    end
  end
end
