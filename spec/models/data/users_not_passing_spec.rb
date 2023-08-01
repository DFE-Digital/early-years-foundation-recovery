require 'rails_helper'

RSpec.describe Data::UsersNotPassing do
  let(:user_1) { create(:user, :registered) }
  let(:user_2) { create(:user, :registered) }

  let(:headers) do
    [
      'Module',
      'Total Users Not Passing',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'module_1',
        count: 1,
      },
    ]
  end

  before do
    create :user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1'
    create :user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1'
    create :user_assessment, :failed, user_id: user_2.id, score: 0, module: 'module_1'
  end

  it_behaves_like 'a data export model'
end
