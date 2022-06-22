require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'email confirmation / account activation' do
    context 'when signing up' do
      it 'send activation email to correct user' do
        response = user.send_confirmation_instructions
        expect(response.recipients).to contain_exactly(user.email)
        expect(response.subject).to eq 'Activation instructions'
      end
    end

    context 'when already signed up' do
      it 'send confirmation email to correct user' do
        user.registration_complete = true
        response = user.send_confirmation_instructions
        expect(response.recipients).to contain_exactly(user.email)
        expect(response.subject).to eq 'Confirmation instructions'
      end
    end
  end

  describe 'reset password instructions' do
    context 'when resetting password' do
      it 'send instructions to correct user' do
        mail = described_class.reset_password_instructions(user, :anything)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Reset password instructions'
      end
    end
  end

  describe 'password change' do
    context 'when changing password' do
      it 'send confirmation to correct user' do
        response = user.send_password_change_notification
        expect(response.recipients).to contain_exactly(user.email)
        expect(response.subject).to eq 'Password change'
      end
    end
  end

  describe 'email change' do
    context 'when changing email' do
      it 'send confirmation to correct user' do
        response = user.send_email_changed_notification
        expect(response.recipients).to contain_exactly(user.email)
        expect(response.subject).to eq 'Email changed'
      end
    end
  end

  describe 'unlock email' do
    context 'when account is locked' do
      it 'send unlock email to correct user' do
        mail = described_class.unlock_instructions(user, :anything)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Unlock instructions'
      end
    end
  end
end
