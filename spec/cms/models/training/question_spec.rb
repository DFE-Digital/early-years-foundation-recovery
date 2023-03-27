require 'rails_helper'

RSpec.describe Training::Question, :cms, type: :model do
  subject(:question) do
    described_class.find_by(name: '1-1-4', training_module: { name: 'alpha' }).load.first
  end

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  describe 'attributes' do
    let(:first_option) { question.options.first }
    let(:last_option) { question.options.last }

    it '#options' do
      expect(question.options.count).to eq(2)

      expect(first_option.label).to eq 'Correct answer 1'
      expect(first_option.id).to eq 1
      expect(first_option.correct?).to be true

      expect(last_option.label).to eq 'Wrong answer 1'
      expect(last_option.id).to eq 2
      expect(last_option.correct?).to be false
    end

    it '#correct_answers' do
      expect(question.correct_answers).to eq [1]
    end

    it '#multi_select?' do
      expect(question.multi_select?).to be false
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
    end
  end
end
