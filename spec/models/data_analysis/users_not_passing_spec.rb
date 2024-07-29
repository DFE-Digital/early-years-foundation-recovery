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
        count: 2,
      },
      {
        module_name: 'bravo',
        count: 0,
      },
      {
        module_name: 'charlie',
        count: 0,
      },
    ]
  end

  let(:user_one) { create :user, :registered }
  let(:user_two) { create :user, :registered }
  let(:user_three) { create :user, :registered }

  before do
    create :assessment, :failed, user: user_one
    create :assessment, :failed, user: user_one
    create :assessment, :failed, user: user_one

    create :assessment, :failed, user: user_two
    create :assessment, :passed, user: user_two

    create :assessment, :failed, user: user_three
  end

  it_behaves_like 'a data export model'
end
