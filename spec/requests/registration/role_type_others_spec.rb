require 'rails_helper'

RSpec.describe 'Registration custom roles', type: :request do
  subject(:user) do
    create :user, :named,
           setting_type_id: Trainee::Setting.all.sample.name
  end

  before { sign_in user }

  describe 'GET /registration/role_type_other/edit' do
    it 'returns http success' do
      get edit_registration_role_type_other_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type_other' do
    let(:update_user) do
      patch registration_role_type_other_path, params: {
        user: {
          role_type_other: role,
        },
      }
    end

    context 'with custom role' do
      let(:role) { 'user defined role' }

      it 'updates role_type_other' do
        expect { update_user }.to change { user.reload.role_type_other }.to(role)
      end

      it 'updates role_type' do
        expect { update_user }.to change { user.reload.role_type }.to('other')
      end

      it 'redirects to my training email preference' do
        update_user
        expect(response).to redirect_to edit_registration_training_emails_path
      end
    end
  end
end
