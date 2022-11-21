require 'rails_helper'

RSpec.describe 'Registration local authority', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type_with_role_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/local_authority/edit' do
    it 'returns http success' do
      get edit_registration_local_authority_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/local_authority' do
    let(:update_user) do
      patch registration_local_authority_path, params: { user: user_params }
    end

    context 'and adds local authority to user' do
      let(:user_params) do
        {
          local_authority: LocalAuthority.first.name,
        }
      end

      it 'Updates user local authority' do
        expect { update_user }.to change { user.reload.local_authority }.to(user_params[:local_authority])
      end

      it 'redirects to role type' do
        update_user
        expect(response).to redirect_to(edit_registration_role_type_path)
      end
    end
  end
end
