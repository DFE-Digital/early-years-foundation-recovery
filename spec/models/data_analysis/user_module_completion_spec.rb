require 'rails_helper'

RSpec.describe DataAnalysis::UserModuleCompletion do
  let(:headers) do
    [
      'Module Name',
      'Completed Count',
      'Completed Percentage',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        completed_count: 1,
        completed_percentage: 0.3333333333333333,
      },
      {
        module_name: 'bravo',
        completed_count: 0,
        completed_percentage: 0.0,
      },
      {
        module_name: 'charlie',
        completed_count: 0,
        completed_percentage: 0.0,
      },
    ]
  end

  before do
    create :user, :confirmed
    create :user, :registered
    # User started but not completed alpha
    user_in_progress = create :user, :registered
    create :user_module_progress, user: user_in_progress, module_name: 'alpha', started_at: 1.day.ago, completed_at: nil
    # User completed alpha
    user_completed = create :user, :registered
    create :user_module_progress, user: user_completed, module_name: 'alpha', started_at: 2.days.ago, completed_at: 1.day.ago
  end

  it_behaves_like 'a data export model'
end
