require 'rails_helper'

RSpec.describe Registration::LocalAuthoritiesController, type: :controller do
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
    let(:confirmed_user) { create :user, :confirmed, :name, :setting_type_with_role_type }

    before { sign_in confirmed_user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { local_authority: 'A Local Authority' } }
        expect(response).to redirect_to edit_registration_role_type_path
      end
    end
  end
end
