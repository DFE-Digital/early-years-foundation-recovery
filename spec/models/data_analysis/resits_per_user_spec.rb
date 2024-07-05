require 'rails_helper'

RSpec.describe DataAnalysis::ResitsPerUser do
  let(:headers) do
    [
      'Module',
      'User ID',
      'Role',
      'Resit Attempts',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        user_id: user_1.id,
        role_type: 'resit',
        resit_attempts: 1,
      },
      {
        module_name: 'alpha',
        user_id: user_3.id,
        role_type: 'failing',
        resit_attempts: 2,
      },
    ]
  end

  let(:user_1) { create :user, :registered, role_type: 'resit' }
  let(:user_2) { create :user, :registered, role_type: 'hole-in-one' }
  let(:user_3) { create :user, :registered, role_type: 'failing' }

  before do
    create :assessment, :failed, user: user_1
    create :assessment, :passed, user: user_1

    create :assessment, :passed, user: user_2

    create :assessment, :failed, user: user_3
    create :assessment, :failed, user: user_3
    create :assessment, :failed, user: user_3
  end

  it_behaves_like 'a data export model'
end
