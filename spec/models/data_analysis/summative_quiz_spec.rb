require 'rails_helper'

RSpec.describe DataAnalysis::SummativeQuiz do
  let(:user_1) { create :user, :agency_childminder }
  let(:user_2) { create :user, :agency_childminder }

  before do
    create :user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1'
    create :user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1'
    create :user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1'
    create :user_assessment, :failed, user_id: user_2.id, score: 0, module: 'module_1'
  end

  describe '.pass_rate' do
    let(:role_type) { described_class.pass_rate(:role_type) }
    let(:setting_type) { described_class.pass_rate(:setting_type) }

    it 'calculates pass and fail values by User attribute' do
      expect(role_type).to eq(
        {
          'Childminder' => {
            fail_count: 2,
            fail_percentage: 0.5,
            pass_count: 2,
            pass_percentage: 0.5,
          },
        },
      )

      expect(setting_type).to eq(
        {
          'Childminder as part of an agency' => {
            fail_count: 2,
            fail_percentage: 0.5,
            pass_count: 2,
            pass_percentage: 0.5,
          },
        },
      )
    end
  end
end
