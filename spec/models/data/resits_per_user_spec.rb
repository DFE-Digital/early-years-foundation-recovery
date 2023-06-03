require 'rails_helper'

RSpec.describe Data::ResitsPerUser do
  let!(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder') }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }

  describe '.resit_attempts_per_user_csv' do
    context 'when users have resat summative assessments' do
      it 'generates csv with number of resits per user' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(described_class.to_csv).to eq("Module,User ID,Role,Resit Attempts\nmodule_1,#{user_1.id},#{user_1.role_type},1\n")
      end
    end

    context 'when users have not resat summative assessments' do
      it 'generates a csv with only column headers' do
        expect(described_class.to_csv).to eq("Module,User ID,Role,Resit Attempts\n")
      end
    end
  end
end
