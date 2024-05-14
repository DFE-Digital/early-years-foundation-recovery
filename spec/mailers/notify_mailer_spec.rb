require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:mod) { Training::Module.first }
  let(:mailbox) { User.new(email: 'child-development.training@education.gov.uk') }

  describe 'users without email preferences' do
    context 'when registration incomplete and opted-in to emails' do
      subject(:mail) { described_class.complete_registration(user) }

      it 'sends reminder email' do
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Complete registration'
      end
    end

    context 'when registration complete and training not started' do
      subject(:mail) { described_class.start_training(user) }

      it 'sends reminder email' do
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Start training'
      end
    end

    context 'when training started but not completed' do
      subject(:mail) { described_class.continue_training(user, mod) }

      it 'sends reminder email' do
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'Continue training'
      end
    end

    context 'when all available modules completed and a new module is released' do
      subject(:mail) { described_class.new_module(user, mod) }

      it 'sends notification email' do
        expect(mail.to).to contain_exactly(user.email)
        expect(mail.subject).to eq 'New module'
      end
    end
  end

  describe 'mail delivery' do
    subject(:delivery) do
      NotifyDelivery.new(api_key: Rails.application.credentials.notify_api_key)
    end

    let(:mail) { described_class.new_module(user, mod) }

    context 'when an error is raised' do
      before do
        allow(mail).to receive(:to).and_raise(StandardError)
      end

      it 'skips' do
        expect(delivery.deliver!(mail)).to eq :skipped_due_to_error
      end

      it 'logs' do
        expect { delivery.deliver!(mail) }.to output(/This is a GOV.UK Notify email with template/).to_stdout_from_any_process
      end
    end
  end
end
