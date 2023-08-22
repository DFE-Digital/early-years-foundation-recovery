require 'rails_helper'

RSpec.describe 'Registration settings', type: :request do
  subject(:user) { create(:user, :confirmed) }

  before { sign_in user }

  describe 'GET /registration/setting_type/edit' do
    it 'returns http success' do
      get edit_registration_setting_type_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/setting_type' do
    let(:update_user) do
      patch registration_setting_type_path, params: {
        user: {
          # setting_type: 'Private Nursery,
          setting_type_id: setting,
        },
      }
    end

    context 'with setting' do
      let(:setting) { 'nursery_private' }

      it 'updates user names' do
        expect { update_user }.to change { user.reload.setting_type_id }.to(setting)
      end

      it 'redirects to local authority form' do
        update_user
        expect(response).to redirect_to edit_registration_local_authority_path
      end
    end
  end
end
