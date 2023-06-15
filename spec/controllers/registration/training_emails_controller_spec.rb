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

  context 'when confirmed user signed in' do
    let(:confirmed_user) { create :user, :confirmed, :name, :emails_opt_in }

    before { sign_in confirmed_user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { training_emails: 'true' } }
        expect(response).to redirect_to edit_registration_early_years_emails_path
        expect(confirmed_user.reload.training_emails).to eq true
      end
    end
  end
end
