require 'rails_helper'

RSpec.describe MailJob do
  describe '.recipients' do
    it 'expects a scope to filter users' do
      expect { described_class.recipients }.to raise_error NoMethodError, "undefined method `mail_job_recipients' for User:Class"
    end
  end

  describe '.template' do
    it 'derives the template name from the job class' do
      expect(described_class.template).to eq :mail_job
    end
  end

  describe '.template_id' do
    before do
      allow(described_class).to receive(:template).and_return(:test_bulk)
    end

    it 'returns the Gov UK Notify template identifier' do
      expect(described_class.template_id).to eq '7c5fa953-4208-4bc4-919a-4ede23db65c1'
    end
  end

  describe '.enqueue?' do
    it 'defaults to false in test environments' do
      expect(described_class).not_to be_enqueue
    end
  end
end
