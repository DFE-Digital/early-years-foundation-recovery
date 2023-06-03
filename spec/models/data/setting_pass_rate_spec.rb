require 'rails_helper'

RSpec.describe Data::SettingPassRate do
  let!(:user_1) { create(:user, :registered, :agency_setting) }
  let!(:user_2) { create(:user, :registered, :agency_setting) }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }
  let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1') }

  describe '.setting_pass_percentage_csv' do
    context 'when summative assessments exist' do
      it 'generates csv with average pass and fail percentage for each role type' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(described_class.to_csv).to eq("Setting,Average Pass Percentage,Pass Count,Average Fail Percentage,Fail Count\nChildminder as part of an agency,66.67%,2,33.33%,1\n")
      end
    end
  end
end
