require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  subject(:user_answer) do
    create(:user_answer,
           name: question.slug,
           module: question.module_id,
           questionnaire_id: question.id)
  end

  let(:question) do
    Training::Question.find_by(slug: '1-1-1-1b', module_id: 'child-development-and-the-eyfs').first
  end

  it 'is associated with a question' do
    expect(user_answer.question).to be_a(Training::Question)
    expect(user_answer.question.id).to eql "1_self_efficacy" 
  end
end
