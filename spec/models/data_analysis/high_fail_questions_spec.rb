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
        module_name: 'alpha',
        question_name: '1-3-2-2',
        fail_rate_percentage: 1.0,
      },
    ]
  end

  before do
    if Rails.application.migrated_answers?
      create :response,
             question_type: 'summative',
             training_module: 'alpha',
             question_name: '1-3-2-1',
             answers: [1],
             correct: true

      create :response,
             question_type: 'summative',
             training_module: 'bravo',
             question_name: '1-3-2-1',
             answers: [1],
             correct: true

      create :response,
             question_type: 'summative',
             training_module: 'alpha',
             question_name: '1-3-2-2',
             answers: [2],
             correct: false

      create :response,
             question_type: 'summative',
             training_module: 'alpha',
             question_name: '1-3-2-2',
             answers: [2],
             correct: false

    else
      create(:user_answer, :correct, :questionnaire, :summative, module: 'alpha', name: '1-3-2-1')
      create(:user_answer, :correct, :questionnaire, :summative, module: 'bravo', name: '1-3-2-1')
      create(:user_answer, :incorrect, :questionnaire, :summative, module: 'alpha', name: '1-3-2-2')
      create(:user_answer, :incorrect, :questionnaire, :summative, module: 'alpha', name: '1-3-2-2')
    end
  end

  it_behaves_like 'a data export model'
end
