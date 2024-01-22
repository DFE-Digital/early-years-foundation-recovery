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

  let(:user_1) { create :user, :agency_childminder }
  let(:user_2) { create :user, :agency_childminder }

  before do
    if Rails.application.migrated_answers?
      create :assessment, :failed, user: user_1
      create :assessment, :passed, user: user_1
      create :assessment, :passed, user: user_2
    else
      create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'alpha')
      create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'alpha')
      create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'alpha')
    end
  end

  it_behaves_like 'a data export model'
end
