require 'rails_helper'

RSpec.describe Data::SummativeQuiz do
  let!(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder') }
  let!(:user_2) { create(:user, :registered, :agency_setting, role_type: 'childminder') }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }
  let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1') }
  let(:assessment_fail_2) { create(:user_assessment, :failed, user_id: user_2.id, score: 0, module: 'module_1') }

  describe '.attribute_pass_percentage' do
    context 'when summative assessments exist' do
      it 'generates a hash with average pass and fail percentage for each attribute type' do
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(assessment_fail_2.score).to eq('0')
        expect(described_class.attribute_pass_percentage(:role_type)).to eq({ 'childminder' => { fail_count: 2, fail_percentage: 0.5, pass_count: 2, pass_percentage: 0.5 } })
        expect(described_class.attribute_pass_percentage(:setting_type)).to eq({ 'Childminder as part of an agency' => { fail_count: 2, fail_percentage: 0.5, pass_count: 2, pass_percentage: 0.5 } })
      end
    end
  end
end
