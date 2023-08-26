require 'rails_helper'

RSpec.describe 'Registration custom settings', type: :request do
  subject(:user) { create :user, :named }

  before { sign_in user }

  describe 'GET /registration/setting_type_other/edit' do
    it 'returns http success' do
      get edit_registration_setting_type_other_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/setting_type_other' do
    let(:update_user) do
      patch registration_setting_type_other_path, params: {
        user: {
          setting_type_other: setting,
        },
      }
    end

    context 'with custom setting' do
      let(:setting) { 'user defined setting' }

      it 'updates setting_type_other' do
        expect { update_user }.to change { user.reload.setting_type_other }.to(setting)
      end

      it 'updates setting_type_id' do
        expect { update_user }.to change { user.reload.setting_type_id }.to('other')
      end

      it 'redirects to local authority form' do
        update_user
        expect(response).to redirect_to edit_registration_local_authority_path
      end
    end
  end
end
