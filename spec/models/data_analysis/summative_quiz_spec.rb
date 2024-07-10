require 'rails_helper'

RSpec.describe DataAnalysis::SummativeQuiz do
  let(:user_1) { create :user, :agency_childminder }
  let(:user_2) { create :user, :agency_childminder }

  before do
    create :assessment, :failed, user: user_1
    create :assessment, :passed, user: user_1
    create :assessment, :failed, user: user_2
    create :assessment, :passed, user: user_2
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
