require 'rails_helper'

RSpec.describe Training, type: :model do
  describe ".load_file" do
    let(:training_data) { data_from_file("training/supporting-physical-development.yml") }
    let(:training) { described_class.find_by(training_module: 'supporting-physical-development') }

    it "loads models from expected path" do
      expect(training.title).to eq(training_data.dig('supporting-physical-development', 'sections', 'one', 'title'))
    end

    it "uses sections keys to populate name" do
      expect(training.name).to eq('one')
    end

    it "uses root key to store training module" do
      expect(training.training_module).to eq(training_data.keys.first)
    end
  end
end
