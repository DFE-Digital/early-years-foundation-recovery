require 'rails_helper'

RSpec.describe Registration::TrainingEmailsController, type: :controller do
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
        it 'succeeds' do
          post :update, params: { user: { training_emails: 'true' } }
          expect(response).to redirect_to my_modules_path
          expect(user.reload.training_emails).to be true
        end
      end

      context 'and other times' do
        let(:user) { create :user, :registered }

        it 'succeeds' do
          post :update, params: { user: { training_emails: 'false' } }
          expect(response).to redirect_to user_path
          expect(user.reload.training_emails).to be false
        end
      end
    end
  end
end
