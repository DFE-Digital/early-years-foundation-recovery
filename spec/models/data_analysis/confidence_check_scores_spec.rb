require 'rails_helper'

RSpec.describe DataAnalysis::ConfidenceCheckScores do
  before do
    skip unless Rails.application.migrated_answers?

    create(:response, question_type: 'confidence', training_module: 'module_1', question_name: 'q1', answers: [1])
    create(:response, question_type: 'confidence', training_module: 'module_1', question_name: 'q2', answers: [2])
    create(:response, question_type: 'confidence', training_module: 'module_1', question_name: 'q2', answers: [2])
  end

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
        module_name: 'module_1',
        question_name: 'q1',
        answers: [1],
        count: 1,
      },
      {
        module_name: 'module_1',
        question_name: 'q2',
        answers: [2],
        count: 2,
      },
    ]
  end

  it_behaves_like 'a data export model'
end
