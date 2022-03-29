require 'rails_helper'

RSpec.describe "User", type: :request do
  describe "Registered user, signed in" do
    let(:user) { create :user, :registered }

    before { sign_in user }

    describe "GET /user" do
      it "renders page" do
        get user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /user/edit" do
      it "renders page" do
        get edit_user_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "patch /user" do
      let(:first_name) { "Foo-Bar" }

      subject { patch user_path, params: { user: { first_name: first_name } } }

      it "updates the user" do
        expect { subject }.to change(user.reload, :first_name).to(first_name)
      end

      it "redirects back to the show page" do
        expect(subject).to redirect_to(user_path)
      end
    end
  end

  describe "Unconfirmed user, not signed in" do
    let(:unconfirmed_user) { create :user }

    describe "GET /user/check_email" do
      it "renders check email page" do
        get check_email_user_path(id: unconfirmed_user)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Check your email")
        expect(response.body).to include(unconfirmed_user.email)
      end
    end
  end
end
