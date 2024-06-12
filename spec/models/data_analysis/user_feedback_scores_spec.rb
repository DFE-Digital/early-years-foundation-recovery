require 'rails_helper'

RSpec.describe DataAnalysis::UserFeedbackScores do
  let(:user_1) { create :user, :agency_childminder }
  let(:user_2) { create :user, :independent_childminder }
  let(:headers) do
    [
      'User ID',
      'Role',
      'Custom Role',
      'Setting',
      'Custom Setting',
      'Local Authority',
      'Years Experience',
      'Module',
      'Question',
      'Answers',
    ]
  end
  let(:rows) do
    [
      {
        user_id: user_1.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Childminder as part of an agency',
        setting_type_other: nil,
        local_authority: 'Hertfordshire',
        early_years_experience: '6-9',
        training_module: 'course',
        question_name: 'feedback-checkbox-only',
        answers: [1, 2],
      },
      {
        user_id: user_1.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Childminder as part of an agency',
        setting_type_other: nil,
        local_authority: 'Hertfordshire',
        early_years_experience: '6-9',
        training_module: 'course',
        question_name: 'feedback-textarea-only',
        answers: [],
      },
      {
        user_id: user_2.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-checkbox-only',
        answers: [1, 2, 3, 4],
      },
      {
        user_id: user_2.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-radio-only',
        answers: [1],
      },
      {
        user_id: user_2.id,
        role_type: 'Childminder',
        role_type_other: nil,
        setting_type: 'Independent childminder',
        setting_type_other: nil,
        local_authority: 'Leeds',
        early_years_experience: '0-2',
        training_module: 'alpha',
        question_name: 'feedback-textarea-only',
        answers: [],
      },
    ]
  end

  before do
    skip unless Rails.application.migrated_answers?

    # guests not included
    create(:response, user: nil, visit: Visit.new, question_type: 'feedback', training_module: 'course', question_name: 'feedback-radio-only', answers: [1])

    # course
    create(:response, user: user_1, question_type: 'feedback', training_module: 'course', question_name: 'feedback-checkbox-only', answers: [1, 2])
    create(:response, user: user_1, question_type: 'feedback', training_module: 'course', question_name: 'feedback-textarea-only', text_input: 'potential PII', answers: [])

    # module
    create(:response, user: user_2, question_type: 'feedback', training_module: 'alpha', question_name: 'feedback-radio-only', answers: [1])
    create(:response, user: user_2, question_type: 'feedback', training_module: 'alpha', question_name: 'feedback-checkbox-only', answers: [1, 2, 3, 4])
    create(:response, user: user_2, question_type: 'feedback', training_module: 'alpha', question_name: 'feedback-textarea-only', text_input: 'potential PII', answers: [])
  end

  it_behaves_like 'a data export model'
end
