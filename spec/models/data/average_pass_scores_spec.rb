require 'rails_helper'

RSpec.describe Data::AveragePassScores do
  let!(:user_1) { create(:user, :registered) }

  let(:headers) do
    ['Module', 'Average Pass Score']
  end

  let(:rows) do
    [
      {
        module_name: 'module_1',
        pass_score: 100.0,
      },
    ]
  end

  before do
    create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1')
    create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1')
  end

  it_behaves_like('a data export model')
end
