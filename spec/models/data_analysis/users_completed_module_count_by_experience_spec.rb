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

  let(:rows) do
    [
      { experience: '0-2', modules_completed: 0, user_count: 1 },
      { experience: '0-2', modules_completed: 1, user_count: 2 },
      { experience: '0-2', modules_completed: 2, user_count: 1 },
      { experience: '3-5', modules_completed: 0, user_count: 1 },
      { experience: '3-5', modules_completed: 1, user_count: 1 },
      { experience: '5+',  modules_completed: 3, user_count: 1 },
      { experience: 'na', modules_completed: 0, user_count: 1 },
    ]
  end

  before do
    # Experience 0-2
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => nil, 'Module 2' => nil }) # 0 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => nil }) # 1 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => nil }) # 1 completed
    create(:user, early_years_experience: '0-2',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => Time.zone.now }) # 2 completed

    # Experience 3-5
    create(:user, early_years_experience: '3-5',
                  module_time_to_completion: { 'Module 1' => nil }) # 0 completed
    create(:user, early_years_experience: '3-5',
                  module_time_to_completion: { 'Module 1' => Time.zone.now }) # 1 completed

    # Experience 5+
    create(:user, early_years_experience: '5+',
                  module_time_to_completion: { 'Module 1' => Time.zone.now, 'Module 2' => Time.zone.now, 'Module 3' => Time.zone.now }) # 3 completed

    # Experience na
    create(:user, early_years_experience: 'na',
                  module_time_to_completion: { 'Module 1' => nil }) # 0 completed
  end

  it_behaves_like 'a data export model'
end
