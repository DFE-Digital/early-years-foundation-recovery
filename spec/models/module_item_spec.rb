require 'rails_helper'

RSpec.describe ModuleItem, type: :model do
  let(:yaml_data) { data_from_file('modules/test.yml') }
  let(:module_item) { described_class.where(training_module: :test).first }

  after do
    described_class.delete_all
    described_class.reload(true)
  end

  it 'loads data from file' do
    expect(module_item.type).to eq(yaml_data.dig('test', module_item.name, 'type'))
  end

  # scopes ---------------------------------

  describe '.where_topic' do
    let!(:topic_one_item) { create :module_item, name: '1-1-1' }
    let!(:topic_two_item) { create :module_item, name: '1-1-2' }

    it 'returns module items matching the topic' do
      expect(described_class.where_topic(:test, 1)).to include(topic_one_item)
      expect(described_class.where_topic(:test, 2)).to include(topic_two_item)
    end

    it 'does not return items from other topics' do
      expect(described_class.where_topic(:test, 1)).not_to include(topic_two_item)
      expect(described_class.where_topic(:test, 2)).not_to include(topic_one_item)
    end
  end

  describe '.where_submodule' do
  end

  describe '.where_type' do
  end

  # sequence ---------------------------------

  describe '#next_item' do
    let(:next_module_item) { described_class.where(training_module: :test).to_a[1] }

    it 'returns the next module item' do
      expect(module_item.next_item).to eq(next_module_item)
    end

    context 'when item is last item' do
      let(:last_module_item) { described_class.where(training_module: :test).last }

      it 'returns nil' do
        expect(last_module_item.next_item).to be_nil
      end
    end
  end

  describe '#previous_item' do
    let(:first_module_item) { module_item }
    let(:second_module_item) { described_class.where(training_module: :test).to_a[1] }

    it 'returns the previous module item' do
      expect(second_module_item.previous_item).to eq(first_module_item)
    end

    context 'when item is first item' do
      it 'returns nil' do
        expect(first_module_item.previous_item).to be_nil
      end
    end
  end

  describe '#model' do
    let(:module_item) { described_class.find_by(training_module: :test, type: :text_page) }
    let(:model) { module_item.model }

    it 'returns the match model object' do
      expect(model).to be_a(ContentPage)
    end

    it 'includes module item data' do
      expect(model.type).to eq(module_item.type)
      expect(model.name).to eq(module_item.name)
    end

    context 'when model is a questionnaire' do
      let(:module_item) { described_class.find_by(training_module: :test, type: :formative_assessment) }

      it 'returns a questionnaire' do
        expect(model).to be_a(Questionnaire)
      end

      it 'matches the module item' do
        expect(model.name).to eq(module_item.name)
      end
    end

    context 'when model is a youtube page' do
      let(:module_item) { described_class.find_by(training_module: :test, type: :youtube_page) }

      it 'returns a Youtube page' do
        expect(model).to be_a(YoutubePage)
      end

      it 'matches the module item' do
        expect(model.name).to eq(module_item.name)
      end
    end
  end

  # names ---------------------------------

  describe '#topic_name' do
    let(:topic) { Faker::Number.number(digits: 2).to_s }
    let(:module_item) { create :module_item, name: "22-1-#{topic}" }

    it 'extracts the topic number from the name' do
      expect(module_item.topic_name).to eq(topic)
    end

    context 'with topic subpage' do
      let(:module_item) { create :module_item, name: "33-22-#{topic}-3" }

      it 'extracts the topic number from the name' do
        expect(module_item.topic_name).to eq(topic)
      end
    end
  end

  describe '#submodule_name' do
  end

  describe '#page_name' do
  end

  # position ---------------------------------

  describe '#position_within_topic' do
    let!(:topic_item_one) { create :module_item, name: '1-1-2' }
    let!(:topic_item_two) { create :module_item, name: '1-1-2-1' }
    let!(:topic_item_three) { create :module_item, name: '1-1-2-5' }

    it 'returns the position of the item within the topic' do
      expect(topic_item_one.position_within_topic).to eq(0)
      expect(topic_item_two.position_within_topic).to eq(1)
    end

    it 'uses position in array rather than last digit in name' do
      expect(topic_item_three.position_within_topic).to eq(2)
    end
  end

  describe '#position_within_training_module' do
    let(:first_item) { described_class.find_by(training_module: :test) }
    let(:last_item) { described_class.where(training_module: :test).last }

    it 'return position in array of module items in training module' do
      expect(first_item.position_within_training_module).to eq(0)
      expect(last_item.position_within_training_module).to eq(described_class.where(training_module: :test).count - 1)
    end
  end

  describe '#position_within_submodule' do
  end

  # counters ---------------------------------

  describe '#number_within_submodule' do
  end

  describe '#number_within_topic' do
  end

  # predicates ---------------------------------

  describe '#topic?' do
  end

  describe '#submodule?' do
  end
end
