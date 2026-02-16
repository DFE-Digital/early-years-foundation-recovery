require 'rails_helper'

RSpec.describe DataAnalysis::PreConfidenceCheckAnswers do
  let(:user_one) { create(:user, :registered) }
  let(:headers) do
    %w[
      user_id
      training_module
      question_type
      question_name
      answer
      created_at
    ]
  end
  let(:rows) do
    [
      {
        user_id: user_one.id,
        training_module: 'alpha',
        question_type: 'confidence',
        question_name: '1-3-3-1',
        answer: [1],
        created_at: Time.zone.local(2024, 1, 2),
      },
      {
        user_id: user_one.id,
        training_module: 'alpha',
        question_type: 'confidence',
        question_name: '1-3-3-2',
        answer: [2],
        created_at: Time.zone.local(2024, 1, 2),
      },
    ]
  end

  before do
    create(:response, user: user_one, question_type: 'confidence', training_module: 'alpha', question_name: '1-3-3-1', answers: [1], created_at: Time.zone.local(2024, 1, 2))
    create(:response, user: user_one, question_type: 'confidence', training_module: 'alpha', question_name: '1-3-3-2', answers: [2], created_at: Time.zone.local(2024, 1, 2))
  end

  it_behaves_like 'a data export model'
end
