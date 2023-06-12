require 'rails_helper'

RSpec.describe 'Registration role type', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/role_type/edit' do
    it 'returns http success' do
      get edit_registration_role_type_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type' do
    let(:update_user) do
      patch registration_role_type_path, params: { user: user_params }
    end

    context 'and role type' do
      let(:user_params) do
        {
          role_type: RoleType.first.name,
        }
      end

      it 'Updates user role type' do
        expect { update_user }.to change { user.reload.role_type }.to(user_params[:role_type])
      end

      it 'redirects to my training email preference' do
        update_user
        expect(response).to redirect_to(edit_registration_training_email_opt_in_path)
      end
    end
  end
end
