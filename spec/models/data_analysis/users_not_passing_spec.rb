require 'rails_helper'

RSpec.describe DataAnalysis::UsersNotPassing do
  let(:headers) do
    [
      'Module',
      'Total Users Not Passing',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        count: 1,
      },
    ]
  end

  let(:user_1) { create :user, :registered }
  let(:user_2) { create :user, :registered }

  before do
    create :assessment, :failed, user: user_1
    create :assessment, :failed, user: user_2
    create :assessment, :passed, user: user_2
  end

  it_behaves_like 'a data export model'
end
