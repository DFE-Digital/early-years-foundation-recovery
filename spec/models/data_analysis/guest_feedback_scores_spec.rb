require 'rails_helper'

RSpec.describe DataAnalysis::GuestFeedbackScores do
  let(:user) { create :user, :registered }
  let(:guest) { Guest.new(visit: Visit.new) }
  let(:headers) do
    %w[
      Guest
      Question
      Answers
    ]
  end
  let(:rows) do
    [
      {
        visit_id: guest.visit.id,
        question_name: 'feedback-checkbox-only',
        answers: [1, 2],
      },
      {
        visit_id: guest.visit.id,
        question_name: 'feedback-radio-only',
        answers: [1],
      },
    ]
  end

  before do
    skip unless Rails.application.migrated_answers?

    # users not included
    create(:response, question_type: 'feedback', training_module: 'course', question_name: 'feedback-checkbox-only', answers: [1, 2])
    create(:response, question_type: 'feedback', training_module: 'alpha', question_name: 'feedback-textarea-only', text_input: 'opinion', answers: [])

    # guest responses
    create(:response, user: nil, visit: guest.visit, question_type: 'feedback', training_module: 'course', question_name: 'feedback-radio-only', answers: [1])
    create(:response, user: nil, visit: guest.visit, question_type: 'feedback', training_module: 'course', question_name: 'feedback-checkbox-only', answers: [1, 2])
  end

  it_behaves_like 'a data export model'
end
