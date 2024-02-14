require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:mailbox) { User.new(email: 'child-development.training@education.gov.uk') }

  describe 'email address taken' do
    context 'when email is taken' do
      it 'send email to user to tell them how to access their account' do
        mail = described_class.email_taken(user)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Email taken'
      end
    end
  end

  describe 'users without email preferences' do
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

    context 'when user started training and not completed training' do
      it 'sends email to user to remind them to complete training' do
        mail = described_class.continue_training(user, Training::Module.first)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Continue training'
      end
    end

    context 'when user has completed all available modules and a new module is released' do
      it 'sends email to user to inform them of new module' do
        mail = described_class.new_module(user, Training::Module.first)
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'New module'
      end
    end
  end
end
