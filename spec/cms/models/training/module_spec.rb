require 'rails_helper'

RSpec.describe Training::Module, :cms, type: :model do
  subject(:mod) { described_class.by_name(:alpha) }

  before do
    skip 'WIP' unless Rails.application.cms?
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
