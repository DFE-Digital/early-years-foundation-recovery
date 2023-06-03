require 'rails_helper'

RSpec.describe Data::HighFailQuestions do
  describe '.high_fail_questions_csv' do
    context 'when summative assessments exist' do
      let(:answer_correct_1) { create(:user_answer, :correct, :questionnaire, :summative, module: 'module_1', name: 'q1') }
      let(:answer_correct_2) { create(:user_answer, :correct, :questionnaire, :summative, module: 'module_2', name: 'q1') }
      let(:answer_incorrect_1) { create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2') }
      let(:answer_incorrect_2) { create(:user_answer, :incorrect, :questionnaire, :summative, module: 'module_1', name: 'q2') }

      it 'returns any questions with a fail rate higher than the average' do
        expect(answer_correct_1.correct).to eq(true)
        expect(answer_correct_2.correct).to eq(true)
        expect(answer_incorrect_1.correct).to eq(false)
        expect(answer_incorrect_2.correct).to eq(false)
        expect(described_class.to_csv).to eq("Module,Question,Failure Rate Percentage\naverage,,50.0%\nmodule_1,q2,100.0%\n")
      end
    end

    context 'when no summative assessments exist' do
      it 'generates csv where the average is NaN' do
        expect(described_class.to_csv).to eq("Module,Question,Failure Rate Percentage\naverage,,0\n")
      end
    end
  end
end
