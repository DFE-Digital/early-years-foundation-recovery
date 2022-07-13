require 'rails_helper'

# FormativeAssessment
RSpec.describe Questionnaire, type: :model do
  subject(:questionnaire) do
    described_class.find_by!(name: page_name, training_module: training_module_name)
  end

  let(:page_name) { '1-1-4' }
  let(:training_module_name) { 'alpha' }
  let(:passmark) { nil }

  before do
    questionnaire.required_percentage_correct = passmark
  end

  it 'is associated with matching module item' do
    module_item = ModuleItem.find_by(training_module: training_module_name, name: page_name)
    expect(questionnaire.module_item).to eq(module_item)
  end

  context 'with theshold not set' do
    context 'and all answers correct' do
      before do
        questionnaire.question_list.each do |question|
          question.submit_answers(question.correct_answers)
        end
      end

      specify { expect(questionnaire).to be_valid }
    end

    context 'and all answers incorrect' do
      before do
        questionnaire.questions.each_value do |question|
          question.delete(:correct_answers)
        end
      end

      specify { expect(questionnaire).to be_valid }
    end
  end

  context 'with 0% theshold' do
    let(:passmark) { 0 }

    specify { expect(questionnaire).to be_valid }
  end

  context 'with 100% theshold' do
    let(:passmark) { 100 }

    specify { expect(questionnaire).to be_invalid }
  end

  context 'when some answers are correct' do
    before do
      question = questionnaire.question_list.first
      question.submit_answers(question.correct_answers)
    end

    context 'and below threshold' do
      let(:passmark) { 1 }

      specify { expect(questionnaire).to be_valid }
    end

    context 'and above threshold' do
      let(:passmark) { 99 }

      specify { expect(questionnaire).to be_valid }
    end
  end
end
