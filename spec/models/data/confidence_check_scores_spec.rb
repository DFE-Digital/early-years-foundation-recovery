require 'rails_helper'

RSpec.describe Data::ConfidenceCheckScores do
  let(:headers) do 
    [
      'Module',
      'Question',
      'Response',
      'Count', 
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'module_1',
        question_name: 'q1',
        response: 'response_1',
        count: 1,
      },
      {
        module_name: 'module_1',
        question_name: 'q2',
        response: 'response_2',
        count: 2,
      }
    ]
  end

  before do 
    create(:response, :confidence_check, module: 'module_1', question_name: 'q1', response: 'response_1') 
    create(:response, :confidence_check, module: 'module_1', question_name: 'q2', response: 'response_2') 
    create(:response, :confidence_check, module: 'module_1', question_name: 'q2', response: 'response_2') 
  end

  it_behaves_like 'a data export model'
end