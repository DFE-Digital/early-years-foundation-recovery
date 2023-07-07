require 'rails_helper'

RSpec.describe 'Registration training email opt in', type: :request do
  subject(:user) { create(:user, :confirmed, :name, :setting_type, :role_type) }

  before do
    sign_in user
  end

  describe 'GET /registration/training_emails/edit' do
    it 'returns http success' do
      get edit_registration_training_emails_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/training_emails' do
    let(:update_user) do
      patch registration_training_emails_path, params: { user: user_params }
    end

    context 'when training email opt in true in user params' do
      let(:user_params) do
        {
          training_emails: true,
        }
      end

      it 'Updates user defined email preferences' do
        expect { update_user }.to change { user.reload.training_emails }.to(user_params[:training_emails])
      end

      it 'redirects to my training email preference' do
        update_user
        expect(response).to redirect_to(my_modules_path)
      end
    end
  end
end
