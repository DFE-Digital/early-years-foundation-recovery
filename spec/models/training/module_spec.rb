require 'rails_helper'

RSpec.describe Training::Module, :vcr, type: :model do
  before { ContentfulModel.use_preview_api = true }
  let(:training_module) { described_class.find_by(name: 'alpha').first }
  let(:bravo) { described_class.find_by(name: 'bravo').first }
  let(:delta) { described_class.find_by(name: 'delta').first }

  it 'has fields' do
    expect(training_module.fields.keys).to eq(%i[title name thumbnail short_description description objective criteria duration summative_threshold pages position])
  end

  it 'can depend on other modules' do
    expect(bravo.depends_on).to all(be_a(Training::Module))
  end

  describe '#draft?' do
    it 'is false if published' do
      expect(training_module.draft?).to be false
    end
    
    it 'is true if no content pages' do
      expect(delta.draft?).to be_truthy
    end
  end

  describe '#interruption_page' do
    subject(:module_item) { training_module.interruption_page }

    it 'is the first page' do
      # expect(module_item.id).to be 1
      expect(module_item.name).to eql 'what-to-expect'
      expect(module_item.page_type).to eql 'interruption_page'
    end
  end

  describe '#icons_page' do
    subject(:module_item) { training_module.icons_page }

    it 'is the second page' do
      # expect(module_item.id).to be 2
      expect(module_item.name).to eql 'before-you-start'
      expect(module_item.page_type).to eql 'icons_page'
    end
  end

  describe '#intro_page' do
    subject(:module_item) { training_module.intro_page }

    it 'is the third page' do
      # expect(module_item.id).to be 3
      expect(module_item.name).to eql 'intro'
      expect(module_item.page_type).to eql 'module_intro'
    end
  end

  describe '#first_content_page' do
    subject(:module_item) { training_module.first_content_page }

    it 'is the fifth page' do
      # expect(module_item.id).to be 5
      expect(module_item.name).to eql '1-1-1'
    end
  end

  describe '#summary_intro_page' do
    subject(:module_item) { training_module.summary_intro_page }

    it 'is the 15th page' do
      # expect(module_item.id).to be 15
      expect(module_item.name).to eql '1-3'
      expect(module_item.page_type).to eql 'summary_intro'
    end
  end

  describe '#assessment_results_page' do
    subject(:module_item) { training_module.assessment_results_page }

    it 'is the 22nd page' do
      # expect(module_item.id).to be 22
      expect(module_item.name).to eql '1-3-2-5'
      expect(module_item.page_type).to eql 'assessment_results'
    end
  end

  describe '#confidence_intro_page' do
    subject(:module_item) { training_module.confidence_intro_page }

    it 'is the 23rd page' do
      # expect(module_item.id).to be 23
      expect(module_item.name).to eql '1-3-3'
      expect(module_item.page_type).to eql 'confidence_intro'
    end
  end

  describe '#last_page' do
    subject(:module_item) { training_module.last_page }

    it 'is the page before the certificate' do
      # expect(module_item.id).to be 27
      expect(module_item.name).to eql '1-3-3-4'
      expect(module_item.page_type).to eql 'thankyou'
    end
  end
end
