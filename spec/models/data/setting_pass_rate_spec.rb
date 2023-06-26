require 'rails_helper'

RSpec.describe Data::SettingPassRate do
  let(:user_1) { create(:user, :registered, :agency_setting) }
  let(:user_2) { create(:user, :registered, :agency_setting) }

  let(:headers) do
    ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
  end

  let(:rows) do
    [
      {
        setting_type: 'Childminder as part of an agency',
        pass_percentage: 0.6666666666666666,
        pass_count: 2,
        fail_percentage: 0.33333333333333337,
        fail_count: 1
      }
    ]
  end

  before do
    create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1')
    create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1')
  end

  it_behaves_like 'a data export model'
end