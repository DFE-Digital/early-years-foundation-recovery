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

  describe '#first_content_page' do
    subject(:module_item) { training_module.first_content_page }

    it 'is first content page' do
      expect(module_item.id).to be 2
      expect(module_item.name).to eql '1-1'
    end
  end

  describe '#summary_intro_page' do
    subject(:module_item) { training_module.summary_intro_page }

    it 'is the 20th page' do
      expect(module_item.id).to be 20
      expect(module_item.name).to eql '1-3'
      expect(module_item.type).to eql 'summary_intro'
    end
  end

  describe '#assessment_results_page' do
    subject(:module_item) { training_module.assessment_results_page }

    it 'is the 33rd page' do
      expect(module_item.id).to be 33
      expect(module_item.name).to eql '1-3-2-11'
      expect(module_item.type).to eql 'assessment_results'
    end
  end

  describe '#confidence_intro_page' do
    subject(:module_item) { training_module.confidence_intro_page }

    it 'is the 34th page' do
      expect(module_item.id).to be 34
      expect(module_item.name).to eql '1-3-3'
      expect(module_item.type).to eql 'confidence_intro'
    end
  end

  describe '#last_page' do
    subject(:module_item) { training_module.last_page }

    it 'is the page before the certificate' do
      expect(module_item.id).to be 39
      expect(module_item.name).to eql '1-3-3-5'
      expect(module_item.type).to eql 'thankyou'
    end
  end
end
