require 'rails_helper'

RSpec.describe 'Page content (locales/modules)' do
  describe 'pages' do
    include_context 'with questions'
    # List module items that are missing content
    #
    xit 'matches module content (data/modules)' do
      module_names.map do |mod_name|
        module_content = course_content[mod_name].keys
        page_content = I18n.t(mod_name, scope: 'modules').keys.map(&:to_s)

        expect(module_content.count).to eql page_content.count
        # Include these assertions to identify the missing page name
        expect(module_content.difference(page_content)).to be_empty
        expect(page_content.difference(module_content)).to be_empty
      end
    end
  end

  describe 'formative' do
    include_context 'with questions'

    let(:data_dir) { 'data/formative-questionnaires' }
    let(:type) { 'formative_assessment' }

    specify { expect(FormativeQuestionnaire.count).to be 46 }
  end

  describe 'summative' do
    include_context 'with questions'

    let(:data_dir) { 'data/summative-questionnaires' }
    let(:type) { 'summative_assessment' }

    specify { expect(SummativeQuestionnaire.count).to be 24 }
  end

  describe 'confidence' do
    include_context 'with questions'

    let(:data_dir) { 'data/confidence-questionnaires' }
    let(:type) { 'confidence_check' }

    specify { expect(ConfidenceQuestionnaire.count).to be 18 }
  end
end
