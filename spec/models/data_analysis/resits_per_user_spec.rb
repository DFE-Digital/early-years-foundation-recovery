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
        user_id: user_one.id,
        role_type: 'resit',
        resit_attempts: 1,
      },
      {
        module_name: 'alpha',
        user_id: user_three.id,
        role_type: 'failing',
        resit_attempts: 2,
      },
    ]
  end

  let(:user_one) { create :user, :registered, role_type: 'resit' }
  let(:user_two) { create :user, :registered, role_type: 'hole-in-one' }
  let(:user_three) { create :user, :registered, role_type: 'failing' }

  before do
    create :assessment, :failed, user: user_one
    create :assessment, :passed, user: user_one

    create :assessment, :passed, user: user_two

    create :assessment, :failed, user: user_three
    create :assessment, :failed, user: user_three
    create :assessment, :failed, user: user_three
  end

  it_behaves_like 'a data export model'
end
