require 'rails_helper'

RSpec.describe QuestionnaireData, type: :model do
  let(:yaml_data) do
    data_from_file('questionnaires/test.yml')
  end

  let(:questionnaire_data) do
    described_class.find_by!(name: :test, training_module: :test)
  end

  it 'loads questions as a hash' do
    expect(questionnaire_data.questions).to be_a(Hash)
  end

  it 'loads answers within questions with symbolized keys' do
    answers = yaml_data.dig('test', 'test', 'questions', 'one_from_many', 'answers')
    answers.symbolize_keys!
    expect(questionnaire_data.questions.dig(:one_from_many, :answers)).to eq(answers)
  end

  it 'loads correct answers within questions' do
    correct_answers = yaml_data.dig('test', 'test', 'questions', 'one_from_many', 'correct_answers')
    expect(questionnaire_data.questions.dig(:one_from_many, :correct_answers)).to eq(correct_answers)
  end
end
