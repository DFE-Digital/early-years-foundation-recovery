require 'rails_helper'

RSpec.describe 'Registration training email opt in', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type, :role_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/training_email_opt_in/edit' do
    it 'returns http success' do
      get edit_registration_training_email_opt_in_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/training_email_opt_in' do
    let(:update_user) do
      patch registration_training_email_opt_in_path, params: { user: user_params }
    end

    context 'Adds training email opt in true' do
      let(:user_params) do
        {
          training_email_opt_in: true,
        }
      end

      it 'Updates user defined email preferences' do
        expect { update_user }.to change { user.reload.training_email_opt_in }.to(user_params[:training_email_opt_in])
      end

      it 'redirects to my training email preference' do
        update_user
        expect(response).to redirect_to(edit_registration_dfe_email_opt_in_path)
      end
    end
  end
end
