require 'rails_helper'

RSpec.describe 'Registration roles', type: :request do
  subject(:user) do
    create :user, :named,
           setting_type_id: Trainee::Setting.with_roles.sample.name
  end

  before { sign_in user }

  describe 'GET /registration/role_type/edit' do
    it 'returns http success' do
      get edit_registration_role_type_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type' do
    let(:update_user) do
      patch registration_role_type_path, params: {
        user: {
          role_type: role,
        },
      }
    end

    context 'with available option' do
      let(:role) { Trainee::Role.all.sample.name }

      it 'Updates user role type' do
        expect { update_user }.to change { user.reload.role_type }.to(role)
      end

      it 'redirects to training email preference form' do
        update_user
        expect(response).to redirect_to edit_registration_training_emails_path
      end
    end
  end
end
