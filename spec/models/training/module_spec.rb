
require 'rails_helper'

RSpec.describe Training::Module, type: :model do
  let(:training_module) { described_class.find_by(slug: 'child-development-and-the-eyfs').first }

  # sequence ---------------------------------

  describe '#interruption_page' do
    it 'is the first page' do
      expect(training_module.interruption_page.component).to eql 'interruption_page'
      expect(training_module.interruption_page.name).to eql 'what-to-expect'
    end
  end

  describe '#icons_page' do
    it 'is the second page' do
      expect(training_module.icons_page.component).to eql 'icons_page' 
      expect(training_module.icons_page.name).to eql 'before-you-start'
    end
  end

  describe '#intro_page' do
    it 'is the third page' do
      expect(training_module.intro_page.component).to eql 'module_intro' 
      expect(training_module.intro_page.name).to eql 'intro'
    end
  end

  describe '#first_content_page' do
    it 'is the fifth page' do
      expect(training_module.first_content_page.component).to eql 'text_page' 
      expect(training_module.first_content_page.name).to eql '1-1-1'
    end
  end
end