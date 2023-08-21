require 'rails_helper'

RSpec.describe Registration::RoleTypeOthersController, type: :controller do
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
             setting_type_id: Trainee::Setting.all.sample.name
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
        post :update, params: { user: { role_type_other: 'User defined role type' } }
        expect(response).to redirect_to edit_registration_training_emails_path
        expect(user.reload.role_type_other).to eq 'User defined role type'
        expect(user.reload.role_type).to eq 'other'
      end
    end
  end
end
