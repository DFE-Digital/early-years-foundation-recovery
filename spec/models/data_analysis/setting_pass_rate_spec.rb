require 'rails_helper'

RSpec.describe DataAnalysis::SettingPassRate do
  let(:headers) do
    [
      'Setting',
      'Pass Percentage',
      'Pass Count',
      'Fail Percentage',
      'Fail Count',
    ]
  end

  let(:rows) do
    [
      {
        setting_type: 'Childminder as part of an agency',
        pass_percentage: 0.6666666666666666,
        pass_count: 2,
        fail_percentage: 0.33333333333333337,
        fail_count: 1,
      },
    ]
  end

  let(:user_one) { create :user, :agency_childminder }
  let(:user_two) { create :user, :agency_childminder }

  before do
    create :assessment, :failed, user: user_one
    create :assessment, :passed, user: user_one
    create :assessment, :passed, user: user_two
  end

  it_behaves_like 'a data export model'
end
