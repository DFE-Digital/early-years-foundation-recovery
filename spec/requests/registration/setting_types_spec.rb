require 'rails_helper'

RSpec.describe 'Registration name', type: :request do
  subject(:user) { create(:user, :confirmed) }

  before do
    sign_in user
  end

  describe 'GET /registration/name/edit' do
    it 'returns http success' do
      get edit_registration_name_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/name' do
    let(:update_user) do
      patch registration_name_path, params: { user: user_params }
    end

    context 'and adds first name to user' do
      let(:user_params) do
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
        }
      end

      it 'Updates user name' do
        expect { update_user }.to change { user.reload.first_name }.to(user_params[:first_name])
      end

      it 'redirects to setting type' do
        update_user
        expect(response).to redirect_to(edit_registration_setting_type_path)
      end
    end
  end
end
