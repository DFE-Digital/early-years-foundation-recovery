require 'rails_helper'

RSpec.describe DataAnalysis::ModulesPerMonth do
  let(:headers) do
    [
      'Month',
      'Module',
      'Pass Percentage',
      'Pass Count',
      'Fail Percentage',
      'Fail Count',
    ]
  end

  let(:rows) do
    [
      {
        month: 'January 2023',
        module_name: 'alpha',
        pass_percentage: 0.5,
        pass_count: 1,
        fail_percentage: 0.5,
        fail_count: 1,
      },
      {
        month: 'February 2023',
        module_name: 'alpha',
        pass_percentage: 0.0,
        pass_count: 0,
        fail_percentage: 1.0,
        fail_count: 1,
      },
      {
        month: 'March 2023',
        module_name: 'alpha',
        pass_percentage: 1.0,
        pass_count: 1,
        fail_percentage: 0.0,
        fail_count: 0,
      },
    ]
  end

  let(:user_1) { create :user, :registered }
  let(:user_2) { create :user, :registered }

  before do
    create :assessment, :failed, user: user_1, completed_at: Time.zone.local(2023, 1, 1)
    create :assessment, :passed, user: user_1, completed_at: Time.zone.local(2023, 1, 1)
    create :assessment, :failed, user: user_1, completed_at: Time.zone.local(2023, 2, 1)
    create :assessment, :passed, user: user_2, completed_at: Time.zone.local(2023, 3, 1)
  end

  it_behaves_like 'a data export model'
end
