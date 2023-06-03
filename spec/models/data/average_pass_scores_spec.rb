require 'rails_helper'

RSpec.describe Data::AveragePassScores do
  let!(:user_1) { create(:user, :registered) }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }

  describe '.average_pass_scores_csv' do
    context 'when summative assessments exist with a passed status' do
      it 'generates csv with average pass score for each module' do
        expect(assessment_pass_1.score).to eq('100')
        expect(described_class.to_csv).to eq("Module,Average Pass Score\nmodule_1,100.0\n")
      end
    end

    context 'when summative assessments exist with a failed status' do
      it 'generates csv with average pass score for each module' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(described_class.to_csv).to eq("Module,Average Pass Score\nmodule_1,100.0\n")
      end
    end
  end
end
