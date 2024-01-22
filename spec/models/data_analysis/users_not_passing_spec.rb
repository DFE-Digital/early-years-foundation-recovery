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
    if Rails.application.migrated_answers?
      create :assessment, :failed, user: user_1
      create :assessment, :failed, user: user_2
      create :assessment, :passed, user: user_2
    else
      create :user_assessment, :failed, user_id: user_1.id, score: 0, module: 'alpha'
      create :user_assessment, :passed, user_id: user_2.id, score: 80, module: 'alpha'
      create :user_assessment, :failed, user_id: user_2.id, score: 0, module: 'alpha'
    end
  end

  it_behaves_like 'a data export model'
end
