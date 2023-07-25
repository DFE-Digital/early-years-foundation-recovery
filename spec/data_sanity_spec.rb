require 'rails_helper'

RSpec.describe 'Module content' do
  before do
    skip 'DEPRECATED' if Rails.application.cms?
  end

  describe 'pages' do
    include_context 'with content'

    it 'has none missing' do
      module_names.map do |mod_name|
        expect(mod_name).to be_publishable
        expect(mod_name).to have_all_types
      end
    end

    it 'has essential attributes' do
      module_names.map do |mod_name|
        I18n.t(mod_name, scope: 'modules').each do |page, attributes|
          case course_content[mod_name][page.to_s]['type']
          when /text/
            expect(attributes).to include :heading, :body
          when /video/
            expect(attributes).to include :heading, :body, :video
          when /thankyou/
            expect(attributes).to include :form
          when /interruption|assessment|confidence|questionnaire/
            expect(attributes).to be_nil
          end
        end
      end
    end
  end

  describe 'formative' do
    include_context 'with content'

    let(:data_dir) { 'data/formative-questionnaires' }
    let(:type) { 'formative_questionnaire' }

    specify do
      expect(questions['alpha'].count).to be 3
      expect(questions['bravo'].count).to be 1
      expect(questions['charlie'].count).to be 1

      expect(questions['child-development-and-the-eyfs'].count).to be 17
      expect(questions['brain-development-and-how-children-learn'].count).to be 22
      expect(questions['personal-social-and-emotional-development'].count).to be 19
      expect(questions['module-4'].count).to be 19
      expect(questions['module-5'].count).to be 13

      expect(questions_total).to be 95
    end
  end

  describe 'summative' do
    include_context 'with content'

    let(:data_dir) { 'data/summative-questionnaires' }
    let(:type) { 'summative_questionnaire' }

    specify do
      expect(questions['alpha'].count).to be 4
      expect(questions['bravo'].count).to be 2
      expect(questions['charlie'].count).to be 2

      expect(questions['child-development-and-the-eyfs'].count).to be 10
      expect(questions['brain-development-and-how-children-learn'].count).to be 10
      expect(questions['personal-social-and-emotional-development'].count).to be 10
      expect(questions['module-4'].count).to be 10
      expect(questions['module-5'].count).to be 10

      expect(questions_total).to be 58
    end
  end

  describe 'confidence' do
    include_context 'with content'

    let(:data_dir) { 'data/confidence-questionnaires' }
    let(:type) { 'confidence_questionnaire' }

    specify do
      expect(questions['alpha'].count).to be 3
      expect(questions['bravo'].count).to be 3
      expect(questions['charlie'].count).to be 3

      expect(questions['child-development-and-the-eyfs'].count).to be 5
      expect(questions['brain-development-and-how-children-learn'].count).to be 4
      expect(questions['personal-social-and-emotional-development'].count).to be 6
      expect(questions['module-4'].count).to be 6
      expect(questions['module-5'].count).to be 5

      expect(questions_total).to be 35
    end
  end
end
