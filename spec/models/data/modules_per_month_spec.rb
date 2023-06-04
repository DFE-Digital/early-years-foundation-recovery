require 'rails_helper'

RSpec.describe Data::ModulesPerMonth do
  let!(:user_1) { create(:user, :registered, :agency_setting) }
  let!(:user_2) { create(:user, :registered, :agency_setting) }
  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1', created_at: Time.zone.local(2023, 1, 1)) }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1', created_at: Time.zone.local(2023, 2, 1)) }
  let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1', created_at: Time.zone.local(2023, 3, 1)) }
  let(:assessment_fail_2) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1', created_at: Time.zone.local(2023, 1, 1)) }

  describe '.module_pass_percentages_by_month' do
    context 'when multiple summative assessments exist' do
      it 'generates csv with average pass and fail rate per module per month' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(assessment_fail_2.score).to eq('0')
        expect(described_class.to_csv).to eq("Month,Module,Pass Percentage,Pass Count,Fail Percentage,Fail Count\nJanuary 2023,module_1,50.0%,1,50.0%,1\nFebruary 2023,module_1,0.0%,0,100.0%,1\nMarch 2023,module_1,100.0%,1,0.0%,0\n")
      end
    end

    context 'when assessments for multiple modules have the same month' do
      it 'generates csv with average pass and fail rate per module for that month' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_2.score).to eq('0')
        expect(described_class.to_csv).to eq("Month,Module,Pass Percentage,Pass Count,Fail Percentage,Fail Count\nJanuary 2023,module_1,50.0%,1,50.0%,1\n")
      end
    end
  end
end
