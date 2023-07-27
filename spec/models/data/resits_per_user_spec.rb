require 'rails_helper'

RSpec.describe Data::ResitsPerUser do
  let(:headers) do
    ['Module', 'User ID', 'Role', 'Resit Attempts']
  end

  let(:rows) do
    [
      {
        module_name: 'module_1',
        user_id: user_1.id,
        role_type: 'resit',
        resit_attempts: 1,
      },
      {
        module_name: 'module_1',
        user_id: user_3.id,
        role_type: 'failing',
        resit_attempts: 2,
      },
    ]
  end

  let(:user_1) { create(:user, :registered, role_type: 'resit') }
  let(:user_2) { create(:user, :registered, role_type: 'hole-in-one') }
  let(:user_3) { create(:user, :registered, role_type: 'failing') }

  before do
    create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1')

    create(:user_assessment, :passed, user_id: user_2.id, score: 90, module: 'module_1')

    create(:user_assessment, :failed, user_id: user_3.id, score: 10, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_3.id, score: 20, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_3.id, score: 30, module: 'module_1')
  end

  it_behaves_like 'a data export model'
end
