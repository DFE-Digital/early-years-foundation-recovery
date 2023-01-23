require 'rails_helper'

RSpec.describe UserAnswer, :vcr, type: :model do
  subject(:user_answer) do
    create(:user_answer,
           name: questionnaire.name,
           module: questionnaire.training_module,
           questionnaire_id: questionnaire.id)
  end

  let(:questionnaire) do
    Questionnaire.find_by!(name: '1-1-4', training_module: 'alpha')
  end

  it 'is associated with a questionnaire' do
    expect(user_answer.questionnaire).to be_a(Questionnaire)
    expect(user_answer.questionnaire.questions.keys).to eql [:alpha_question_one]
  end
end
