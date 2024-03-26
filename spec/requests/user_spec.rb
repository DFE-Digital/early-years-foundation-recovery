require 'rails_helper'

RSpec.describe 'User', type: :request do
  describe 'Registered user, signed in' do
    subject(:user) { create :user, :registered }

    before { sign_in user }

    describe 'GET /user' do
      it 'renders my account page' do
        get user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /user/edit-name' do
      it 'renders edit name form' do
        get edit_registration_name_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch /user/update-name' do
      let(:update_user) do
        patch registration_name_path, params: { user: { first_name: first_name, last_name: user.last_name } }
      end

      let(:first_name) { 'Foo-Bar' }

      it "updates the user's name" do
        expect { update_user }.to change(user.reload, :first_name).to(first_name)
      end

      it 'redirects back to the account page' do
        expect(update_user).to redirect_to(user_path)
      end
    end
  end
end
