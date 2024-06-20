require 'rails_helper'

RSpec.describe DataAnalysis::HighFailQuestions do
  let(:headers) do
    [
      'Module',
      'Question',
      'Failure Rate Percentage',
    ]
  end

  let(:rows) do
    [
      {
        module_name: :average,
        question_name: nil,
        fail_rate_percentage: 0.5,
      },
      {
        module_name: 'module_1',
        question_name: 'q2',
        fail_rate_percentage: 1.0,
      },
    ]
  end

  before do
    create :response,
           question_type: 'summative',
           training_module: 'module_1',
           question_name: 'q1',
           answers: [1],
           correct: true

    create :response,
           question_type: 'summative',
           training_module: 'module_2',
           question_name: 'q1',
           answers: [1],
           correct: true

    create :response,
           question_type: 'summative',
           training_module: 'module_1',
           question_name: 'q2',
           answers: [2],
           correct: false

    create :response,
           question_type: 'summative',
           training_module: 'module_1',
           question_name: 'q2',
           answers: [2],
           correct: false
  end

  it_behaves_like 'a data export model'
end
