require 'rails_helper'

RSpec.describe Data::HighFailQuestions do
  let(:headers) do
    ['Module', 'Question', 'Failure Rate Percentage']
  end

  let(:rows) do
    {
      module_name: [:average, 'module_1'],
      question_name: [nil, 'q2'],
      fail_rate_percentage: [0.5, 1.0],
    }
  end

  before do
    create(:user_answer, :correct, :questionnaire, :summative, module: 'module_1', name: 'q1')
    create(:user_answer, :correct, :questionnaire, :summative, module: 'module_2', name: 'q1')
    create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2')
    create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2')
  end

  it_behaves_like('a data export model')
end
