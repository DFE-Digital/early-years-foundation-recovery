require 'rails_helper'

RSpec.describe Registration::EarlyYearsEmailsController, type: :controller do
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
    let(:confirmed_user) { create :user, :confirmed, :name, :emails_opt_in, :setting_type, :role_type }

    before { sign_in confirmed_user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { early_years_emails: 'true' } }
        expect(confirmed_user.reload.early_years_emails).to eq true
        expect(response).to redirect_to my_modules_path
        expect(confirmed_user.reload).to be_registration_complete
      end
    end
  end
end