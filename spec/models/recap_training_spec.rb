require 'rails_helper'

RSpec.describe RecapTraining, type: :model do
  describe ".load_file" do
    let(:training_data) { data_from_file("training/supporting-physical-development.yml") }
    let(:recap_training) { described_class.first }

    it "loads models from expected path" do
      expect(recap_training.title).to eq(training_data.dig('supporting-physical-development', 'recap', 'title'))
    end

    it "uses root key to store training module" do
      expect(recap_training.training_module).to eq(training_data.keys.first)
    end
  end
end
