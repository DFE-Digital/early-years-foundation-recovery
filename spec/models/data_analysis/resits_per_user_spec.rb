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
    if Rails.application.migrated_answers?
      create :assessment, :failed, user: user_1
      create :assessment, :passed, user: user_1

      create :assessment, :passed, user: user_2

      create :assessment, :failed, user: user_3
      create :assessment, :failed, user: user_3
      create :assessment, :failed, user: user_3
    else
      create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'alpha')
      create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'alpha')

      create(:user_assessment, :passed, user_id: user_2.id, score: 90, module: 'alpha')

      create(:user_assessment, :failed, user_id: user_3.id, score: 10, module: 'alpha')
      create(:user_assessment, :failed, user_id: user_3.id, score: 20, module: 'alpha')
      create(:user_assessment, :failed, user_id: user_3.id, score: 30, module: 'alpha')
    end
  end

  it_behaves_like 'a data export model'
end
