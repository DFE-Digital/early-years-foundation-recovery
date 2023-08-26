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

  context 'when signed in' do
    let(:user) do
      create :user, :named,
             setting_type_id: Trainee::Setting.all.sample.name,
             role_type: Trainee::Role.all.sample.name,
             training_emails: true
    end

    before { sign_in user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { early_years_emails: 'true' } }
        expect(response).to redirect_to my_modules_path
        expect(user.reload.registration_complete).to be true
        expect(user.reload.early_years_emails).to be true
      end
    end
  end
end
