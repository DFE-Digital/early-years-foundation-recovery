require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  let(:questionnaire) { described_class.find_by!(name: :test, training_module: :test) }

  it 'is associated with matching module item' do
    module_item = ModuleItem.find_by(training_module: :test, name: :test)
    expect(questionnaire.module_item).to eq(module_item)
  end

  context 'with zero required_percentage_correct' do
    before do
      questionnaire.required_percentage_correct = 0
    end

    it 'is valid' do
      expect(questionnaire).to be_valid
    end
  end

  context 'with required_percentage_correct set' do
    before do
      questionnaire.required_percentage_correct = 100
    end

    it 'is invalid' do
      expect(questionnaire).to be_invalid
    end
  end

  context 'with required_percentage_correct not set and all answers correct' do
    before do
      questionnaire.required_percentage_correct = nil
      questionnaire.question_list.each do |question|
        question.set_answer(answer: question.correct_answers)
      end
    end

    it 'is valid' do
      expect(questionnaire).to be_valid
    end
  end

  context 'with a question correct and required_percentage_correct not set' do
    before do
      questionnaire.required_percentage_correct = nil
      question, data = questionnaire.questions.first
      questionnaire.send("#{question}=", data[:correct_answers])
    end

    it 'is valid' do
      expect(questionnaire).to be_invalid
    end
  end

  context 'with a question correct and below required_percentage_correct threshold' do
    before do
      questionnaire.required_percentage_correct = 1
      question = questionnaire.question_list.first
      question.set_answer(answer: question.correct_answers)
    end

    it 'is valid' do
      expect(questionnaire).to be_valid
    end
  end

  context 'with a question correct and above required_percentage_correct threshold' do
    before do
      questionnaire.required_percentage_correct = 99
      question, data = questionnaire.questions.first
      questionnaire.send("#{question}=", data[:correct_answers])
    end

    it 'is valid' do
      expect(questionnaire).to be_invalid
    end
  end

  context 'with required_percentage_correct not set and no correct answers' do
    before do
      questionnaire.required_percentage_correct = nil
      questionnaire.questions.each_value { |question| question.delete(:correct_answers) }
    end

    it 'is valid' do
      expect(questionnaire).to be_valid
    end
  end
end
