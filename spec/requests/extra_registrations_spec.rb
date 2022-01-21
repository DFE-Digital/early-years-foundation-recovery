require 'rails_helper'

RSpec.describe "ExtraRegistrations", type: :request do
  let(:steps) { ExtraRegistrationsController::STEPS }
  let(:user) { create(:user, :confirmed) }

  before do
    sign_in user
  end

  describe "GET /extra_registrations" do
    it "redirects to first step" do
      get "/extra_registrations"
      expect(response).to redirect_to(edit_extra_registration_path(steps.first))
    end
  end

  describe "GET /extra_registrations/:id/edit" do
    it "returns http success" do
      get edit_extra_registration_path(steps.first)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /extra_registrations/:id" do
    context "Adds first name to user" do
      let(:step) { :name }
      let(:user_params) do
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name
        }
      end
      subject do
        patch extra_registration_path(step), params: { user: user_params }
      end

      it "Updates user name" do
        expect { subject }.to change { user.reload.first_name }.to(user_params[:first_name])
      end

      it "redirects to next step" do
        next_step = steps[steps.index(step) + 1]
        subject
        expect(response).to redirect_to(edit_extra_registration_path(next_step))
      end
    end

    context "last step" do
      let(:step) { :setting }
      let(:user_params) do
        {
          postcode: Faker::Address.postcode,
        }
      end
      subject do
        patch extra_registration_path(step), params: { user: user_params }
      end

      it "Updates user name" do
        expect { subject }.to change { user.reload.postcode }.to(user_params[:postcode])
      end

      it "redirects to root" do
        subject
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
