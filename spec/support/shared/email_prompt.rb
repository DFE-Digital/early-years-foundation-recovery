# @example
#   Define the following variables:
#
#   - included: array of users who should receive an email
#   - excluded: array of users who should not receive an email
#
RSpec.shared_examples 'an email prompt' do |job_vars, mailer_vars|
  describe '#run' do
    it 'messages the correct users' do
      expect(included).to eq described_class.recipients
      expect(excluded).not_to eq described_class.recipients
    end

    it 'uses the correct template' do
      email = instance_double(ActionMailer::MessageDelivery, deliver_now: true, deliver_later: true)

      described_class.recipients.each do |recipient|
        allow(NotifyMailer).to receive(described_class.template).with(recipient, *mailer_vars).and_return(email)
      end

      described_class.run(*job_vars)
    end

    it 'prevents concurrent duplicates of the same class' do
      expect { described_class.run(*job_vars) }.not_to raise_error
      create :job, job_class: described_class.name # Job to run
      create :job, job_class: described_class.name # Duplicate
      expect { described_class.run(*job_vars) }.to raise_error ApplicationJob::DuplicateJobError
    end

    it 'logs delivery event' do
      expect(MailEvent.count).to be_zero
      described_class.run(*job_vars)
      expect(MailEvent.count).to eq included.size
    end
  end
end
