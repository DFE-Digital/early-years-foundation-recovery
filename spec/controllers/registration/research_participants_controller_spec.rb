require 'rails_helper'

RSpec.describe Registration::ResearchParticipantsController, type: :controller do
  context 'when not signed in' do
    describe 'GET #edit' do
      it 'redirects' do
        get :edit
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'POST #update' do
      it 'redirects' do
        post :update
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context 'when signed in' do
    let(:user) { create :user, :registered, registration_complete: false }

    before { sign_in user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      context 'and first time' do
        it 'redirects to check your answers' do
          post :update, params: { user: { research_participant: 'true' } }
          expect(response).to redirect_to edit_registration_check_your_answers_path
          expect(user.reload.research_participant).to be true
        end
      end

      context 'and other times' do
        let(:user) { create :user, :registered }

        it 'succeeds' do
          post :update, params: { user: { research_participant: 'false' } }
          expect(response).to redirect_to user_path
          expect(user.reload.research_participant).to be false
        end
      end
    end
  end
end
