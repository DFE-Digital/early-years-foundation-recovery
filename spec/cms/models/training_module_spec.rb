require 'rails_helper'

RSpec.describe Training::Module, :cms, type: :model do
  subject(:mod) { described_class.by_name(:alpha) }

  describe '.by_name' do
    it 'does not load linked entries' do
      # binding.pry
      mod.content # tests cache loading
      expect(mod.pages).to be_empty
    end
  end

  describe 'attributes' do
    it '#title' do
      mod.content # tests cache loading
      # binding.pry
      expect(mod.title).to eq 'First Training Module (cms)'
    end
  end

  describe 'YAML conversion' do
    let(:attributes) { TrainingModule.first.cms_module_params }

    it 'migrates fields' do
      mod.content # tests cache loading

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
