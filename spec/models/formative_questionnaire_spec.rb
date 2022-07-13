require 'rails_helper'

RSpec.describe FormativeQuestionnaire, type: :model do
  let(:questionnaire_data) do
    described_class.find_by!(name: '1-2-1-1', training_module: :alpha)
  end

  let(:question_options) do
    questionnaire_data.questions.dig(:alpha_question_two, :answers)
  end

  let(:correct_answers) do
    questionnaire_data.questions.dig(:alpha_question_two, :correct_answers)
  end

  it 'loads questions as a hash' do
    expect(questionnaire_data.questions).to be_a(Hash)
  end

  it 'loads question options with numeric keys' do
    expect(question_options).to eq({
      1 => 'Correct answer 1',
      2 => 'Wrong answer',
      3 => 'Correct answer 2',
    })
  end

  it 'loads correct answers as option key numbers' do
    expect(correct_answers).to eq [1, 3]
  end
end
