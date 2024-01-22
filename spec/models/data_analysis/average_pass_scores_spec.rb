require 'rails_helper'

RSpec.describe DataAnalysis::AveragePassScores do
  let(:headers) do
    [
      'Module',
      'Average Pass Score',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        pass_score: 100.0,
      },
    ]
  end

  let(:user) { create(:user, :registered) }

  before do
    if Rails.application.migrated_answers?
      create :assessment, :passed
      create :assessment, :failed
    else
      create :user_assessment, :passed, user_id: user.id, score: 100, module: 'alpha'
      create :user_assessment, :failed, user_id: user.id, score: 0, module: 'alpha'
    end
  end

  it_behaves_like 'a data export model'
end
