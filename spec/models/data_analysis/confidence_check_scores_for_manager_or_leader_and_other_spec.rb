require 'rails_helper'

RSpec.describe DataAnalysis::ConfidenceCheckScoresForManagerOrLeaderAndOther do
  let(:headers) do
    %w[
      Module
      Question
      Answers
      Count
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        question_name: '1-3-3-1',
        answers: [1],
        count: 1,
      },
      {
        module_name: 'alpha',
        question_name: '1-3-3-2',
        answers: [2],
        count: 2,
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
      answers: [2],
      correct: true,
      user: user_two,
      question_type: 'confidence',
    )

    create(
      :response,
      question_name: '1-3-3-2',
      training_module: 'alpha',
      answers: [2],
      correct: true,
      user: user_three,
      question_type: 'confidence',
    )
  end

  it_behaves_like 'a data export model'
end
