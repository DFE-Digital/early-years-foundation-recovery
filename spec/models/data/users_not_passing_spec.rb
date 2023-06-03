require 'rails_helper'

RSpec.describe Data::UsersNotPassing do
  let!(:user_1) { create(:user, :registered) }
  let!(:user_2) { create(:user, :registered) }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }
  let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1') }
  let(:assessment_fail_2) { create(:user_assessment, :failed, user_id: user_2.id, score: 0, module: 'module_1') }

  describe '.total_users_not_passing_per_module_csv' do
    context 'when no users have failed a summative assessment' do
      it 'generates csv with the column headers' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(described_class.to_csv).to eq("Module,Total Users Not Passing\n")
      end
    end

    context 'when users have failed a summative assessment' do
      it 'generates csv with the number of users who have failed a summative assessment for each module' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_fail_2.score).to eq('0')
        expect(described_class.to_csv).to eq("Module,Total Users Not Passing\nmodule_1,1\n")
      end
    end
  end
end
