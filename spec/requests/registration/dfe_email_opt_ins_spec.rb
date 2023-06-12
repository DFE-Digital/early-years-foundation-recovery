require 'rails_helper'

RSpec.describe 'Registration dfe email opt in', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type, :role_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/dfe_email_opt_in/edit' do
    it 'returns http success' do
      get edit_registration_dfe_email_opt_in_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/dfe_email_opt_in' do
    let(:update_user) do
      patch registration_dfe_email_opt_in_path, params: { user: user_params }
    end

    context 'when dfe email opt in true in user params' do
      let(:user_params) do
        {
          dfe_email_opt_in: true,
        }
      end

      it 'Updates user defined email preferences' do
        expect { update_user }.to change { user.reload.dfe_email_opt_in }.to(user_params[:dfe_email_opt_in])
      end

      it 'redirects to my dfe email preference' do
        update_user
        expect(response).to redirect_to(my_modules_path)
      end
    end
  end
end
