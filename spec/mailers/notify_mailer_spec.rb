require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:user) { create(:user) }
  describe "user sign up" do
    it "is a valid user" do
      expect(user).to be_valid
    end

    context "when signing up" do
      it "send confirmation email to correct user" do
        response = user.send_confirmation_instructions
        expect(response.recipients[0]).to eq user.email
        expect(response.subject).to eq "Confirmation instructions"
      end
    end
  end

  describe "reset password instructions" do
    context "when resetting password" do
      it "send instructions to correct user" do
        response = User.send_reset_password_instructions(email: user.email)
        expect(response.email).to eq user.email
      end
    end
  end

  describe "password change" do
    context "when changing password" do
      it "send confirmation to correct user" do
        response = user.send_password_change_notification
        expect(response.recipients[0]).to eq user.email
        expect(response.subject).to eq 'Password change'
      end
    end
  end

  describe "email change" do
    context "when changing email" do
      it "send confirmation to correct user" do
        response = user.send_email_changed_notification
        expect(response.recipients[0]).to eq user.email
        expect(response.subject).to eq 'Email changed'
      end
    end
  end
end
