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

  context 'when confirmed user signed in' do
    let(:confirmed_user) { create :user, :confirmed, :name, :setting_type }

    before { sign_in confirmed_user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { role_type_other: 'User defined role type' } }
        expect(response).to redirect_to my_modules_path
        expect(confirmed_user.reload).to be_registration_complete
        expect(confirmed_user.role_type_other).to eq 'User defined role type'
        expect(confirmed_user.role_type).to eq 'other'
      end
    end
  end
end
