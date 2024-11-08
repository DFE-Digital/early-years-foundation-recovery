require 'rails_helper'

RSpec.describe 'Registration local authority', type: :request do
  subject(:user) do
    create :user, :named,
           setting_type_id: Trainee::Setting.with_roles.sample.name
  end

  before { sign_in user }

  describe 'GET /registration/local_authority/edit' do
    it 'returns http success' do
      get edit_registration_local_authority_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/local_authority' do
    let(:update_user) do
      patch registration_local_authority_path, params: {
        user: {
          local_authority: local_authority,
        },
      }
    end

    context 'with available option' do
      let(:local_authority) { Trainee::Authority.all.sample.name }

      it 'updates user' do
        expect { update_user }.to change { user.reload.local_authority }.to(local_authority)
      end

      it 'redirects to role form' do
        update_user
        expect(response).to redirect_to(edit_registration_role_type_path)
      end
    end

    context 'with no option' do
      let(:local_authority) { '' }

      it 'does not update user' do
        expect { update_user }.not_to(change { user.reload.local_authority })
      end

      it 'does not redirect' do
        update_user
        expect(response).not_to redirect_to edit_registration_role_type_path
      end
    end
  end
end
