require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  let(:user_answer) { create :user_answer }

  # Testing this association to check ActiveHash associations are working
  it 'is associated with a questionnaire data instance' do
    expect(user_answer.questionnaire_data).to be_a(QuestionnaireData)
  end
end
