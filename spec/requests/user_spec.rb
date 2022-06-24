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
        get edit_name_user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch /user/update-name' do
      let(:update_user) do
        patch update_name_user_path, params: { user: { first_name: first_name } }
      end

      let(:first_name) { 'Foo-Bar' }

      it "updates the user's name" do
        expect { update_user }.to change(user.reload, :first_name).to(first_name)
      end

      it 'redirects back to the account page' do
        expect(update_user).to redirect_to(user_path)
      end
    end

    describe 'GET /user/edit-postcode' do
      it 'renders the edit postcode form' do
        get edit_postcode_user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch /user/update-postcode' do
      let(:update_user) do
        patch update_name_user_path, params: { user: { postcode: 'wd180dn' } }
      end

      it "updates the user's postcode" do
        expect { update_user }.to change(user.reload, :postcode).to('WD18 0DN')
      end

      it 'redirects back to the account page' do
        expect(update_user).to redirect_to(user_path)
      end
    end

    # TODO: spec coverage for user edit forms - email, ofsted_number
    # describe '' do
    # end
  end

  describe 'Unconfirmed user, not signed in' do
    let(:unconfirmed_user) { create :user }

    describe 'GET /user/check-email-confirmation' do
      it 'renders check email page' do
        get check_email_confirmation_user_path(email: unconfirmed_user.email)
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Check your email')
        expect(response.body).to include(unconfirmed_user.email)
      end
    end
  end
end
