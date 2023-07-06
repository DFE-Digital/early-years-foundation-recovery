require 'rails_helper'

RSpec.describe Data::UserModuleCompletion do
  let!(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 1 }) }
  let!(:user_2) { create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: { alpha: 0 }) }
  let!(:user_3) { create(:user, :registered, :agency_setting, role_type: 'childminder', module_time_to_completion: {}) }

  let(:headers) do
    ['alpha Percentage', 'alpha Count', 'bravo Percentage', 'bravo Count', 'charlie Percentage', 'charlie Count']
  end

  let(:rows) do
    [
      {
        alpha_count: 1,
        alpha_percentage: 0.3333333333333333,
        bravo_count: 0,
        bravo_percentage: 0.0,
        charlie_count: 0,
        charlie_percentage: 0.0,
      },
    ]
  end

  it_behaves_like('a data export model')
end
