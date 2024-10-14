require 'rails_helper'

RSpec.describe DataAnalysis::ConfidenceCheckScoresForManagerOrLeader do
  let(:headers) do
    %w[
      role_type
      role_type_other
      training_module
      question_name
      answers
    ]
  end

  let(:rows) do
    [
      {
        role_type: 'Manager or team leader',
        role_type_other: '',
        training_module: 'alpha',
        question_name: '1-3-3-1',
        answers: [1],
      },
      {
        role_type: 'other',
        role_type_other: 'a leader',
        training_module: 'alpha',
        question_name: '1-3-3-2',
        answers: [1],
      },
      {
        role_type: 'other',
        role_type_other: 'a manager',
        training_module: 'alpha',
        question_name: '1-3-3-2',
        answers: [1],
      },
    ]
  end

  before do
    user_one = create :user, role_type: 'Manager or team leader', role_type_other: ''
    user_two = create :user, role_type: 'other', role_type_other: 'a leader'
    user_three = create :user, role_type: 'other', role_type_other: 'a manager'

    create(
      :response,
      question_name: '1-3-3-1',
      training_module: 'alpha',
      answers: [1],
      correct: true,
      user: user_one,
      question_type: 'confidence',
    )

    create(
      :response,
      question_name: '1-3-3-2',
      training_module: 'alpha',
      answers: [1],
      correct: true,
      user: user_two,
      question_type: 'confidence',
    )

    create(
      :response,
      question_name: '1-3-3-2',
      training_module: 'alpha',
      answers: [1],
      correct: true,
      user: user_three,
      question_type: 'confidence',
    )
  end

  it_behaves_like 'a data export model'
end
