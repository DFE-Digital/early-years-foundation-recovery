require 'rails_helper'

RSpec.describe Data::ModulesPerMonth do
  let!(:user_1) { create(:user, :registered, :agency_setting) }
  let!(:user_2) { create(:user, :registered, :agency_setting) }

  let(:headers) do
    ['Month', 'Module', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
  end
  let(:rows) do
    [
      {
        month: 'January 2023',
        module_name: 'module_1',
        pass_count: 1,
        fail_count: 1,
        pass_percentage: 50.0,
        fail_percentage: 50.0,
      },
      {
        month: 'February 2023',
        module_name: 'module_1',
        pass_count: 0,
        fail_count: 1,
        pass_percentage: 0.0,
        fail_percentage: 100.0,
      },
      {
        month: 'March 2023',
        module_name: 'module_1',
        pass_count: 1,
        fail_count: 0,
        pass_percentage: 100.0,
        fail_percentage: 0.0,
      },
    ]
  end

  before do
    create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1', created_at: Time.zone.local(2023, 1, 1))
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1', created_at: Time.zone.local(2023, 2, 1))
    create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1', created_at: Time.zone.local(2023, 3, 1))
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1', created_at: Time.zone.local(2023, 1, 1))
  end

  it_behaves_like('a data export model')
end
