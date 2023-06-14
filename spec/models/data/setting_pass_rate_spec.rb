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
            fail_count: 1,
            fail_percentage:33.33333333333334,
            pass_count: 2,
            pass_percentage: 66.66666666666666,
            type: "Childminder as part of an agency"
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
