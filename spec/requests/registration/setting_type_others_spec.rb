require 'rails_helper'

RSpec.describe 'Registration setting type other', type: :request do
  subject(:user) { create(:user, :confirmed, :name) }

  before do
    sign_in user
  end

  describe 'GET /registration/role_type_other/edit' do
    it 'returns http success' do
      get edit_registration_setting_type_other_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type_other' do
    let(:update_user) do
      patch registration_setting_type_other_path, params: { user: user_params }
    end

    context 'and adds role type other' do
      let(:user_params) do
        {
          setting_type_other: 'A user defined setting type',
        }
      end

      it 'Updates user defined setting type' do
        expect { update_user }.to change { user.reload.setting_type_other }.to(user_params[:setting_type_other])
      end

      it 'redirects to my modules' do
        update_user
        expect(response).to redirect_to(edit_registration_local_authority_path)
      end
    end
  end
end
