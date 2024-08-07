require 'rails_helper'

RSpec.describe DataAnalysis::UserFeedbackScores do
  let(:user_one) { create :user, :agency_childminder }
  let(:user_two) { create :user, :independent_childminder }
  let(:headers) do
    %w[
      user_id
      role_type
      role_type_other
      setting_type
      setting_type_other
      local_authority
      early_years_experience
      training_module
      question_name
      answers
      responses.created_at
      responses.updated_at
    ]
  end
  let(:rows) do
    [
      {
        user_id: user_one.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Childminder as part of an agency',
        setting_type_other: nil,
        local_authority: 'Hertfordshire',
        early_years_experience: '6-9',
        training_module: 'course',
        question_name: 'feedback-checkbox-only',
        answers: [1, 2],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
      {
        user_id: user_one.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Childminder as part of an agency',
        setting_type_other: nil,
        local_authority: 'Hertfordshire',
        early_years_experience: '6-9',
        training_module: 'course',
        question_name: 'feedback-textarea-only',
        answers: [],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
      {
        user_id: user_two.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-checkbox-only',
        answers: [1, 2, 3, 4],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
      {
        user_id: user_two.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-radio-only',
        answers: [1],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
      {
        user_id: user_two.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-textarea-only',
        answers: [],
        created_at: '2023-01-01 00:00:00',
        updated_at: '2023-01-01 00:00:00',
      },
    ]
  end

  before do
    # guests not included
    create(:response,
           user: nil,
           visit: Visit.new,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-radio-only',
           answers: [1])

    # course
    create(:response,
           user: user_one,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-checkbox-only',
           answers: [1, 2],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))
    create(:response,
           user: user_one,
           question_type: 'feedback',
           training_module: 'course',
           question_name: 'feedback-textarea-only',
           text_input: 'potential PII',
           answers: [],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))

    # module
    create(:response,
           user: user_two,
           question_type: 'feedback',
           training_module: 'alpha',
           question_name: 'feedback-radio-only',
           answers: [1],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))
    create(:response,
           user: user_two,
           question_type: 'feedback',
           training_module: 'alpha',
           question_name: 'feedback-checkbox-only',
           answers: [1, 2, 3, 4],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))
    create(:response,
           user: user_two,
           question_type: 'feedback',
           training_module: 'alpha',
           question_name: 'feedback-textarea-only',
           text_input: 'potential PII',
           answers: [],
           created_at: Time.zone.local(2023, 1, 1),
           updated_at: Time.zone.local(2023, 1, 1))
  end

  it_behaves_like 'a data export model'
end
