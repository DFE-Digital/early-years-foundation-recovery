require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:mailbox) { User.new(email: 'child-development.training@education.gov.uk') }

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
        expect(response.subject).to eq 'Email confirmation instructions'
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

  describe 'email address taken' do
    context 'when email is taken' do
      it 'send email to user to tell them how to access their account' do
        mail = described_class.email_taken(user)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Email taken'
      end
    end
  end

  describe 'account closed' do
    context 'when account has been closed' do
      it 'send email to user to confirm account has been closed' do
        mail = described_class.account_closed(user)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Account closed'
      end

      it 'send email to internal mailbox' do
        mail = described_class.account_closed_internal(mailbox, user)
        expect(mail.to).to contain_exactly(mailbox.email)
      end
    end
  end

  describe 'training email opt in' do
    context 'when user not completed registration and not opted out of emails' do
      it 'sends email to user to remind them to complete registration' do
        mail = described_class.complete_registration(user)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Complete registration'
      end
    end

    context 'when user completed registration and not started training' do
      it 'sends email to user to remind them to start' do
        mail = described_class.start_training(user)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Start training'
      end
    end
  end
end
