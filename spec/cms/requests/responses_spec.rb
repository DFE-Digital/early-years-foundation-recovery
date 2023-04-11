require 'rails_helper'

RSpec.describe 'Responses', type: :request do
  let(:user) { create(:user, :registered) }

  before do
    skip 'WIP' unless Rails.application.cms?
    sign_in user
  end

  describe 'GET /modules/:training_module_id/questionnaires/:id' do
    subject(:show_view) do
      get training_module_questionnaire_path(:alpha, '1-1-4')
    end

    before { show_view }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /modules/:training_module_id/questionnaires/:id' do
    context 'when correct (radio buttons)' do
      subject(:submit_questionnaire) do
        patch training_module_questionnaire_path(:alpha, '1-1-4'), params: { response: answers }
      end

      let(:answers) do
        { answer: 1 }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(Response, :count).by(1)
      end
    end

    context 'when correct (check boxes)' do
      subject(:submit_questionnaire) do
        patch training_module_questionnaire_path(:alpha, '1-2-1-1'), params: { response: answers }
      end

      let(:answers) do
        { answer: [1, 3] }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(Response, :count).by(1)
      end
    end

    context 'when incorrect' do
      subject(:submit_questionnaire) do
        patch training_module_questionnaire_path(:alpha, '1-2-1-1'), params: { response: answers }
      end

      let(:answers) do
        { answer: 2 }
      end

      it 'saves the answer' do
        expect { submit_questionnaire }.to change(Response, :count).by(1)
      end
    end

    context 'when unanswered' do
      subject(:submit_questionnaire) do
        patch training_module_questionnaire_path(:alpha, '1-2-1-1'), params: { response: answers }
      end

      let(:answers) do
        { answer: nil }
      end

      it 'does not save the answer' do
        expect { submit_questionnaire }.not_to change(Response, :count)
      end
    end
  end
end
