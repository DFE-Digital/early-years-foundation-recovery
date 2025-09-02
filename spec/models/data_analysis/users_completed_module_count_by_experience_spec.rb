# spec/models/data_analysis/users_completed_module_count_by_experience_spec.rb
require 'rails_helper'

RSpec.describe DataAnalysis::UsersCompletedModuleCountByExperience do
  let(:headers) do
    %w[
      Experience
      ModulesCompleted
      UserCount
    ]
  end

  # Expected output for CSV
  let(:rows) do
    [
      { experience: '0-2', modules_completed: 1, user_count: 1 },
      { experience: '0-2', modules_completed: 2, user_count: 1 },
    ]
  end

  before do
    # User 1: completed 1 module
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: {
                    'Module 1' => Time.zone.now,
                    'Module 2' => nil,
                  })
    # User 2: completed 2 modules
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: {
                    'Module 1' => Time.zone.now,
                    'Module 2' => Time.zone.now,
                  })
  end

  it_behaves_like 'a data export model'
end
