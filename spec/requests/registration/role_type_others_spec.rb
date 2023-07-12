require 'rails_helper'

RSpec.describe 'Registration role type other', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/role_type_other/edit' do
    it 'returns http success' do
      get edit_registration_role_type_other_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type_other' do
    let(:update_user) do
      patch registration_role_type_other_path, params: { user: user_params }
    end

    context 'and adds role type other' do
      let(:user_params) do
        {
          role_type_other: 'A user defined role type',
        }
      end

      it 'Updates user defined role type' do
        expect { update_user }.to change { user.reload.role_type_other }.to(user_params[:role_type_other])
      end

      it 'redirects to my training email preference' do
        update_user
        if Rails.configuration.feature_email_prefs
          expect(response).to redirect_to(edit_registration_training_emails_path)
        else
          expect(response).to redirect_to(my_modules_path)
        end
      end
    end
  end
end
