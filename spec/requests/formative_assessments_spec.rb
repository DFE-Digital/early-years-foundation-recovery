require 'rails_helper'

RSpec.describe 'FormativeAssessments', type: :request do
  let(:user) { create(:user, :registered) }
  let(:questionnaire_data) { module_item.model }
  let(:module_item) do
    ModuleItem.find_by(training_module: :alpha, type: :formative_assessment, name: '1-1-4')
  end

  before { sign_in user }

  describe 'GET /modules/:training_module_id/formative_assessments/:id' do
    subject(:show_view) do
      get training_module_formative_assessment_path(:alpha, questionnaire_data)
    end

    before { show_view }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /modules/:training_module_id/formative_assessments/:id' do
    subject(:submit_questionnaire) do
      patch training_module_formative_assessment_path(:alpha, questionnaire_data), params: { questionnaire: answers }
    end

    context 'when correct (radio buttons)' do
      let(:answers) do
        { alpha_question_one: 'Correct answer 1' }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(UserAnswer, :count).by(1)
      end
    end

    context 'when correct (check boxes)' do
      let(:module_item) do
        ModuleItem.find_by(training_module: :alpha, type: :formative_assessment, name: '1-2-1-1')
      end

      let(:answers) do
        { alpha_question_two: ['Correct answer 1', 'Correct answer 2'] }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(UserAnswer, :count).by(1)
      end
    end

    context 'when incorrect' do
      let(:answers) do
        { alpha_question_one: 'Wrong answer 1' }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(UserAnswer, :count).by(1)
      end
    end

    context 'when unanswered' do
      let(:answers) do
        { alpha_question_one: '' }
      end

      it 'does not save the answer' do
        expect { submit_questionnaire }.not_to change(UserAnswer, :count)
      end
    end
  end
end
