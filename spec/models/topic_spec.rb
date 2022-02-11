require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe ".load_file" do
    let(:training_data) { data_from_file("training/supporting-physical-development.yml") }
    let(:topic) { described_class.find_by(training_module: 'supporting-physical-development') }

    it "loads models from expected path" do
      expect(topic.title).to eq(training_data.dig('supporting-physical-development', 'topics', 'one', 'title'))
    end

    it "uses sections keys to populate name" do
      expect(topic.name).to eq('one')
    end

    it "uses root key to store training module" do
      expect(topic.training_module).to eq(training_data.keys.first)
    end
  end
end
