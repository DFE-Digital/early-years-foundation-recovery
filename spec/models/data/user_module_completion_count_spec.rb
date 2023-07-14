require 'rails_helper'

RSpec.describe Data::UserModuleCompletionCount do
  let(:headers) do
    ['1 Module Count', '2 Modules Count', '3 Modules Count']
  end

  let(:rows) do
    [
      {
        "1 Module Count": 1,
        "2 Modules Count": 2,
        "3 Modules Count": 1,
      },
    ]
  end

  before do
    create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 1 })
    create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 1, charlie: 1 })
    create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 0 })
    create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { bravo: 1, alpha: 1 })
    create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 1, bravo: 1, charlie: 1 })
  end

  it_behaves_like('a data export model')
end
