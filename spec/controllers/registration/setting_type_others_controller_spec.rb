require 'rails_helper'

RSpec.describe Registration::SettingTypeOthersController, type: :controller do
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
    let(:user) { create :user, :named }

    before { sign_in user }

    describe 'GET #edit' do
      it 'succeeds' do
        get :edit
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { setting_type_other: 'User defined setting type' } }
        expect(response).to redirect_to edit_registration_local_authority_path
        expect(user.reload.setting_type_other).to eq 'User defined setting type'
        expect(user.reload.setting_type_id).to eq 'other'
      end
    end
  end
end
