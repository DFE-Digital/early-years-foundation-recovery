require 'rails_helper'

RSpec.describe TrainingModule, type: :model do
  describe '.load_file' do
    let(:training_module_data) { data_from_file('training-modules.yml') }
    let(:training_module) { described_class.first }

    it 'loads models from expected path' do
      expect(training_module.title).to eq(training_module_data.values.first['title'])
    end

    it 'uses root key to store name' do
      expect(training_module.name).to eq(training_module_data.keys.first)
    end
  end
end
