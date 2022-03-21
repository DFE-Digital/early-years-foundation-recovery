require 'rails_helper'

RSpec.describe ModuleItem, type: :model do
  let(:yaml_data) { data_from_file("modules/test.yml") }
  let(:module_item) { described_class.where(training_module: :test).first }

  it "loads data from file" do
    expect(module_item.type).to eq(yaml_data.dig('test', module_item.name, 'type'))
  end

  describe "#next_item" do
    let(:next_module_item) { described_class.where(training_module: :test).to_a[1] }
    
    it "returns the next module item" do
      expect(module_item.next_item).to eq(next_module_item)
    end

    context "when item is last item" do
      let(:last_module_item) { described_class.where(training_module: :test).last }

      it "returns nil" do
        expect(last_module_item.next_item).to be_nil
      end
    end
  end

  describe "#previous_item" do
    let(:first_module_item) { module_item }
    let(:second_module_item) { described_class.where(training_module: :test).to_a[1] }

    it "returns the previous module item" do
      expect(second_module_item.previous_item).to eq(first_module_item)
    end

    context "when item is first item" do
      it "returns nil" do
        expect(first_module_item.previous_item).to be_nil
      end
    end
  end

  describe "#model" do
    let(:module_item) { described_class.find_by(training_module: :test, type: :text_page) }
    let(:model) { module_item.model }

    it "returns the match model object" do
      expect(model).to be_a(ContentPage)
    end

    it "includes module item data" do
      expect(model.type).to eq(module_item.type)
      expect(model.name).to eq(module_item.name)
    end

    context "when model is a questionniare" do
      let(:module_item) { described_class.find_by(training_module: :test, type: :formative_assessment) }

      it "returns a questionnaire" do
        expect(model).to be_a(Questionnaire)
      end

      it "matches the module item" do
        expect(model.name).to eq(module_item.name)
      end
    end

    context "when model is a youtube page" do
      let(:module_item) { described_class.find_by(training_module: :test, type: :youtube_page) }

      it "returns a Youtube page" do
        expect(model).to be_a(YoutubePage)
      end

      it "matches the module item" do
        expect(model.name).to eq(module_item.name)
      end
    end
  end
end
