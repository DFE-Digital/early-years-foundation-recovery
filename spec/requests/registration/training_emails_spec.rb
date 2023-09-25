require 'rails_helper'

RSpec.describe 'Registration training email opt in', type: :request do
  subject(:user) do
    create :user, :named,
           setting_type_id: Trainee::Setting.all.sample.name,
           role_type: Trainee::Role.all.sample.name
  end

  before { sign_in user }

  describe 'GET /registration/training_emails/edit' do
    it 'returns http success' do
      get edit_registration_training_emails_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/training_emails' do
    let(:update_user) do
      patch registration_training_emails_path, params: {
        user: {
          training_emails: true,
        },
      }
    end

    context 'when opting in' do
      it 'updates user preferences' do
        expect { update_user }.to change { user.reload.training_emails }.to(true)
      end

      it 'redirects to my modules' do
        update_user
        expect(response).to redirect_to my_modules_path
      end
    end
  end
end
