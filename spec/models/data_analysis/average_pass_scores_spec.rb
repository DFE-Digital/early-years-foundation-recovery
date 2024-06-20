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
    create :assessment, :passed
    create :assessment, :failed
  end

  it_behaves_like 'a data export model'
end
