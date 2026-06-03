require 'rails_helper'

RSpec.describe Registration::WhereYouLiveController, type: :controller do
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

      it 'preselects where you live from stored country name' do
        user.update!(country: 'England')

        get :edit

        expect(controller.send(:form).where_you_live).to eq 'england'
      end
    end

    describe 'POST #update' do
      it 'succeeds' do
        post :update, params: { user: { where_you_live: 'England' } }
        expect(response).to redirect_to edit_registration_setting_type_path
        expect(user.reload.country).to eq 'England'
      end
    end
  end
end
