require 'rails_helper'

RSpec.describe Training::Question, :cms, type: :model do
  subject(:question) { described_class.find_by(name: '1-1-4').load.first }

  let(:alpha) { Training::Module.by_name(:alpha) }

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  describe 'attributes' do
    it '#options' do
      expect(question.options.count).to eq(2)
      expect(question.options.first).to eq(OpenStruct.new(id: 1, label: 'Correct answer 1', correct?: true))
    end

    it '#correct_answer' do
      expect(question.correct_answer).to eq(1)
    end

    describe 'contentful attributes' do
      it '#page_type' do
        expect(question.page_type).to eq 'formative_questionnaire'
      end

      it '#assessment_type' do
        expect(question.assessments_type).to eq 'formative_assessment'
      end

      it '#submodule' do
        expect(question.submodule).to eq 1
      end

      it '#page_number' do
        expect(question.page_number).to eq 1
      end

      it '#total_questions' do
        expect(question.total_questions).to eq 3
      end
    end
  end
end
