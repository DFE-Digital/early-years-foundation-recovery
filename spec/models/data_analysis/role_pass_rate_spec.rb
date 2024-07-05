require 'rails_helper'

RSpec.describe DataAnalysis::RolePassRate do
  let(:headers) do
    [
      'Role',
      'Pass Percentage',
      'Pass Count',
      'Fail Percentage',
      'Fail Count',
    ]
  end

  let(:rows) do
    [
      {
        role_type: 'childminder',
        pass_percentage: 0.6666666666666666,
        pass_count: 2,
        fail_percentage: 0.33333333333333337,
        fail_count: 1,
      },
    ]
  end

  let(:user_1) { create :user, :registered, role_type: 'childminder' }
  let(:user_2) { create :user, :registered, role_type: 'childminder' }

  before do
    create :assessment, :failed, user: user_1
    create :assessment, :passed, user: user_1
    create :assessment, :passed, user: user_2
  end

  it_behaves_like 'a data export model'
end
