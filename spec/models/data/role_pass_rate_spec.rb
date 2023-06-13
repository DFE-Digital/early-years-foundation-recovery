require 'rails_helper'

RSpec.describe Data::RolePassRate do
  let(:user_1) { create(:user, :registered, role_type: 'childminder') }
  let(:user_2) { create(:user, :registered, role_type: 'childminder') }

  let(:headers) do
    ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
  end

  let(:rows) do
    [
      ['childminder', 66.67, 2, 33.33, 1],
    ]
  end

  before do
    let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
    let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }
    let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1') }
  end

  it_behaves_like('a data export model')
end
