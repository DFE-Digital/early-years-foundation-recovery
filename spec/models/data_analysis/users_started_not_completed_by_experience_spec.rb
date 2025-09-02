require 'rails_helper'

RSpec.describe DataAnalysis::UsersStartedNotCompletedByExperience do
  let(:headers) do
    %w[Experience ModuleName StartedNotCompleted Completed]
  end

  let(:experience_level) { '0-2' }
  let(:module_time) do
    {
      'Module 1' => nil, # started but not completed
      'Module 2' => Time.zone.now, # completed
    }
  end

  # Expected dashboard output for these two users
  let(:rows) do
    [
      { experience: '0-2', module_name: 'Module 1', started_not_completed: 1, completed: 0 },
      { experience: '0-2', module_name: 'Module 2', started_not_completed: 0, completed: 2 },
    ]
  end

  before do
    create(:user, early_years_experience: experience_level, module_time_to_completion: module_time)
    create(:user, early_years_experience: experience_level, module_time_to_completion: { 'Module 2' => Time.zone.now })
  end

  it_behaves_like 'a data export model'
end
