require 'rails_helper'

RSpec.describe TrainingModule, type: :model do
  let(:training_module) { described_class.first }

  describe '.load_file' do
    let(:training_module_data) { data_from_file('demo-modules.yml') }

    it 'loads models from expected path' do
      expect(training_module.title).to eq(training_module_data.values.first['title'])
    end

    it 'uses root key to store name' do
      expect(training_module.name).to eq(training_module_data.keys.first)
    end
  end

  it 'has fields' do
    expect(training_module.attributes.keys).to eq(%i[title thumbnail short_description description objective criteria duration summative_threshold name id])
  end

  describe '#next_module' do
    it 'returns the next module' do
      expect(training_module.id).to eq 1
      expect(training_module.next_module.id).to eq 2
      expect(training_module.next_module.name).to eq 'bravo'
    end
  end

  describe '#draft?' do
    it 'is false if published' do
      expect(training_module.draft?).to be false
    end
  end

  describe '#interruption_page' do
    subject(:module_item) { training_module.interruption_page }

    it 'is the first page' do
      expect(module_item.id).to be 1
      expect(module_item.name).to eql 'what-to-expect'
      expect(module_item.type).to eql 'interruption_page'
    end
  end

  describe '#icons_page' do
    subject(:module_item) { training_module.icons_page }

    it 'is the second page' do
      expect(module_item.id).to be 2
      expect(module_item.name).to eql 'before-you-start'
      expect(module_item.type).to eql 'icons_page'
    end
  end

  describe '#intro_page' do
    subject(:module_item) { training_module.intro_page }

    it 'is the third page' do
      expect(module_item.id).to be 3
      expect(module_item.name).to eql 'intro'
      expect(module_item.type).to eql 'module_intro'
    end
  end

  describe '#first_content_page' do
    subject(:module_item) { training_module.first_content_page }

    it 'is the fifth page' do
      expect(module_item.id).to be 5
      expect(module_item.name).to eql '1-1-1'
    end
  end

  describe '#summary_intro_page' do
    subject(:module_item) { training_module.summary_intro_page }

    it 'is the 15th page' do
      expect(module_item.id).to be 15
      expect(module_item.name).to eql '1-3'
      expect(module_item.type).to eql 'summary_intro'
    end
  end

  describe '#assessment_results_page' do
    subject(:module_item) { training_module.assessment_results_page }

    it 'is the 22nd page' do
      expect(module_item.id).to be 22
      expect(module_item.name).to eql '1-3-2-5'
      expect(module_item.type).to eql 'assessment_results'
    end
  end

  describe '#confidence_intro_page' do
    subject(:module_item) { training_module.confidence_intro_page }

    it 'is the 23rd page' do
      expect(module_item.id).to be 23
      expect(module_item.name).to eql '1-3-3'
      expect(module_item.type).to eql 'confidence_intro'
    end
  end

  describe '#last_page' do
    subject(:module_item) { training_module.last_page }

    it 'is the page before the certificate' do
      expect(module_item.id).to be 27
      expect(module_item.name).to eql '1-3-3-4'
      expect(module_item.type).to eql 'thankyou'
    end
  end
end
