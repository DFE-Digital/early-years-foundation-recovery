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

  context 'when signed in' do
    subject(:user) do
      create :user, :named,
             setting_type_id: Trainee::Setting.with_roles.sample.name
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
        post :update, params: { user: { local_authority: 'Custom Local Authority' } }
        expect(response).to redirect_to edit_registration_role_type_path
      end
    end
  end
end
