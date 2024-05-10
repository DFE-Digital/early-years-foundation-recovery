require 'rails_helper'

RSpec.describe Registration::EarlyYearsExperiencesController, type: :controller do
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
    let(:user) { create :user, :confirmed }

    before { sign_in user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { early_years_experience: '0-2' } }
        expect(response).to redirect_to edit_registration_training_emails_path
        expect(user.reload.early_years_experience).to eq 'Less than 2 years'
      end
    end
  end
end
