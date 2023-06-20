require 'rails_helper'

RSpec.describe Data::ResitsPerUser do
  let!(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder') }

  let(:headers) do
    ['Module', 'User ID', 'Role', 'Resit Attempts']
  end

  let(:rows) do
    {
      module_name: %w[module_1],
      user_id: [user_1.id],
      role_type: %w[childminder],
      resit_attempts: [1],
    }
  end

  before do
    create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1')
  end

  it_behaves_like('a data export model')
end
