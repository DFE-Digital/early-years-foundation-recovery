require 'rails_helper'

RSpec.describe DataAnalysis::GuestFeedbackScores do
  let(:user) { create :user, :registered }
  let(:guest) { Guest.new(visit: Visit.new) }
  let(:headers) do
    %w[
      Guest
      Question
      Answers
      Created
      Updated
    ]
  end
  let(:rows) do
    [
      {
        visit_id: guest.visit.id,
        question_name: 'feedback-checkbox-only',
        answers: [1, 2],
        created_at: '2024-01-02 00:00:00',
        updated_at: '2024-01-03 00:00:00',
      },
      {
        visit_id: guest.visit.id,
        question_name: 'feedback-radio-only',
        answers: [1],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
    ]
  end

  before do
    # users not included
    create(:response,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-checkbox-only',
           answers: [1, 2])
    create(:response,
           question_type: 'feedback',
           training_module: 'alpha',
           question_name: 'feedback-textarea-only',
           text_input: 'opinion',
           answers: [])

    # guest responses
    create(:response,
           user: nil,
           visit: guest.visit,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-radio-only',
           answers: [1],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))

    create(:response,
           user: nil,
           visit: guest.visit,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-checkbox-only',
           answers: [1, 2],
           created_at: Time.zone.local(2024, 1, 2),
           updated_at: Time.zone.local(2024, 1, 3))
  end

  it_behaves_like 'a data export model'
end
