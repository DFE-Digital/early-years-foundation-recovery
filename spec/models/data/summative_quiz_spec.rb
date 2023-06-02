require 'rails_helper'

RSpec.describe Data::SummativeQuiz do
  let(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder') }
  let(:user_2) { create(:user, :registered, :agency_setting, role_type: 'childminder') }

  let(:assessment_pass_1) { create(:user_assessment, :passed, user_id: user_1.id, score: 100, module: 'module_1') }
  let(:assessment_fail_1) { create(:user_assessment, :failed, user_id: user_1.id, score: 0, module: 'module_1') }
  let(:assessment_pass_2) { create(:user_assessment, :passed, user_id: user_2.id, score: 80, module: 'module_1') }
  let(:assessment_fail_2) { create(:user_assessment, :failed, user_id: user_2.id, score: 0, module: 'module_1') }

  describe '.average_pass_scores_csv' do
    context 'when summative assessments exist with a passed status' do
      it 'generates csv with average pass score for each module' do
        expect(user_1.registration_complete).to eq(true)
        expect(assessment_pass_1.score).to eq('100')
        expect(Data::AveragePassScores.to_csv).to eq("Module,Average Pass Score\nmodule_1,100.0\n")
      end
    end

    context 'when summative assessments exist with a failed status' do
      it 'generates csv with average pass score for each module' do
        expect(user_1.registration_complete).to eq(true)
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(Data::AveragePassScores.to_csv).to eq("Module,Average Pass Score\nmodule_1,100.0\n")
      end
    end
  end

  describe '.high_fail_questions_csv' do
    context 'when summative assessments exist' do
      let(:answer_correct_1) { create(:user_answer, :correct, :questionnaire, :summative, module: 'module_1', name: 'q1') }
      let(:answer_correct_2) { create(:user_answer, :correct, :questionnaire, :summative, module: 'module_2', name: 'q1') }
      let(:answer_incorrect_1) { create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2') }
      let(:answer_incorrect_2) { create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2') }

      it 'returns any questions with a fail rate higher than the average' do
        expect(user_1.registration_complete).to eq(true)
        expect(answer_correct_1.correct).to eq(true)
        expect(answer_incorrect_1.correct).to eq(false)
        expect(answer_correct_2.correct).to eq(true)
        expect(answer_incorrect_2.correct).to eq(false)
        expect(Data::HighFailQuestions.to_csv).to eq("Module,Question,Failure Rate Percentage\naverage,,50.0\nmodule_1,q2,100.0\n")
      end
    end

    context 'when no summative assessments exist' do
      it 'generates csv where the average is NaN' do
        expect(Data::HighFailQuestions.to_csv).to eq("Module,Question,Failure Rate Percentage\naverage,,0\n")
      end
    end
  end

  describe '.role_pass_percentage_csv' do
    context 'when summative assessments exist' do
      it 'generates csv with average pass and fail percentage for each role type' do
        expect(user_1.role_type).to eq('childminder')
        expect(user_2.role_type).to eq('childminder')
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(Data::RolePassRate.to_csv).to eq("Role,Average Pass Percentage,Pass Count,Average Fail Percentage,Fail Count\nchildminder,66.67,2,33.33,1\n")
      end
    end
  end

  describe '.setting_pass_percentage_csv' do
    context 'when summative assessments exist' do
      it 'generates csv with average pass and fail percentage for each role type' do
        expect(user_1.setting_type).to eq('Childminder as part of an agency')
        expect(user_2.setting_type).to eq('Childminder as part of an agency')
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(Data::SettingPassRate.to_csv).to eq("Setting,Average Pass Percentage,Pass Count,Average Fail Percentage,Fail Count\nChildminder as part of an agency,66.67,2,33.33,1\n")
      end
    end
  end

  describe '.total_users_not_passing_per_module_csv' do
    context 'when no users have failed a summative assessment' do
      it 'generates csv with the column headers' do
        expect(user_1.registration_complete).to eq(true)
        expect(user_2.registration_complete).to eq(true)
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_pass_2.score).to eq('80')
        expect(Data::UsersNotPassing.to_csv).to eq("Module,Total Users Not Passing\n")
      end
    end

    context 'when users have failed a summative assessment' do
      it 'generates csv with the number of users who have failed a summative assessment for each module' do
        expect(user_1.registration_complete).to eq(true)
        expect(user_2.registration_complete).to eq(true)
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(assessment_fail_2.score).to eq('0')
        expect(Data::UsersNotPassing.to_csv).to eq("Module,Total Users Not Passing\nmodule_1,1\n")
      end
    end
  end

  describe '.resit_attempts_per_user_csv' do
    context 'when users have resat summative assessments' do
      it 'generates csv with number of resits per user' do
        expect(user_1.registration_complete).to eq(true)
        expect(user_2.registration_complete).to eq(true)
        expect(assessment_pass_1.score).to eq('100')
        expect(assessment_fail_1.score).to eq('0')
        expect(Data::ResitsPerUser.to_csv).to eq("Module,User ID,Role,Resit Attempts\nmodule_1,#{user_1.id},#{user_1.role_type},1\n")
      end
    end

    context 'when users have not resat summative assessments' do
      it 'generates a csv with only column headers' do
        expect(Data::ResitsPerUser.to_csv).to eq("Module,User ID,Role,Resit Attempts\n")
      end
    end
  end
end
