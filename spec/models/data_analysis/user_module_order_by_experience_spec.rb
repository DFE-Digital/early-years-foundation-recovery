require 'rails_helper'

RSpec.describe DataAnalysis::UserModuleOrderByExperience do
  let(:headers) do
    %w[
      Experience
      UserId
      ModuleName
      FirstAccessedAt
      Order
    ]
  end

  # Minimal expected output for the shared example
  let(:rows) do
    # Use exact values matching your before block
    user_a = User.find_by(early_years_experience: '0-2')
    user_b = User.find_by(early_years_experience: '5+')

    [
      { experience: '0-2', user_id: user_a.id, module_name: 'Intro', first_accessed_at: user_a.assessments.find_by(training_module: 'Intro').started_at, order: 1 },
      { experience: '0-2', user_id: user_a.id, module_name: 'Safety', first_accessed_at: user_a.assessments.find_by(training_module: 'Safety').started_at, order: 2 },
      { experience: '5+', user_id: user_b.id, module_name: 'Leadership', first_accessed_at: user_b.assessments.find_by(training_module: 'Leadership').started_at, order: 1 },
    ]
  end

  before do
    user_a = create(:user, early_years_experience: '0-2')
    user_b = create(:user, early_years_experience: '5+')

    create(:assessment, user: user_a, training_module: 'Intro', started_at: 1.day.ago)
    create(:assessment, user: user_a, training_module: 'Safety', started_at: Time.current)
    create(:assessment, user: user_b, training_module: 'Leadership', started_at: 2.days.ago)
  end

  it_behaves_like 'a data export model'
end
