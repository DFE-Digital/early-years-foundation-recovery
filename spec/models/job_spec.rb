require 'rails_helper'

RSpec.describe Job, type: :model do
  before do
    create :job, job_class: 'TestJob'
  end

  it 'queries jobs' do
    expect(described_class.count).to eq 2
    expect(described_class.first.job_class).to eq 'Que::Scheduler::SchedulerJob'
    expect(described_class.last.job_class).to eq 'TestJob'
  end

  it 'has default scopes for state' do
    expect(described_class.ready.count).to eq 2
    expect(described_class.finished.count).to eq 0
    expect(described_class.errored.count).to eq 0
    expect(described_class.expired.count).to eq 0
    expect(described_class.scheduled.count).to eq 0

    expect(described_class.not_ready.count).to eq 0
    expect(described_class.not_errored.count).to eq 2
    expect(described_class.not_expired.count).to eq 2
    expect(described_class.not_finished.count).to eq 2
    expect(described_class.not_scheduled.count).to eq 2
  end

  it 'custom scopes by class' do
    expect(described_class.start_training.count).to eq 0
  end

  describe 'filters queued mail for delivery' do
    it '.mail' do
      expect(described_class.mail.count).to eq 0
      create :job,
             job_class: 'ActionMailer::MailDeliveryJob'
      expect(described_class.mail.count).to eq 1
    end

    it '.test_bulk_mail' do
      expect(described_class.test_bulk_mail.count).to eq 0
      create :job,
             job_class: 'ActionMailer::MailDeliveryJob',
             args: [
               {
                 arguments: %w[NotifyMailer test_bulk deliver_now],
               },
             ]
      expect(described_class.test_bulk_mail.count).to eq 1
    end

    it '.newest_module_mail' do
      expect(described_class.newest_module_mail.count).to eq 0
      create :job,
             job_class: 'ActionMailer::MailDeliveryJob',
             args: [
               {
                 arguments: %w[NotifyMailer new_module deliver_now],
               },
             ]
      expect(described_class.newest_module_mail.count).to eq 1
    end

    it '#mail_user_id' do
      create :user, :registered, id: 1234
      create :job,
             job_class: 'ActionMailer::MailDeliveryJob',
             args: [
               {
                 arguments: [
                   'NotifyMailer',
                   'test_bulk',
                   'deliver_now',
                   {
                     'args': [
                       {
                         '_aj_globalid': 'gid://early-years-foundation-recovery/User/1234',
                       },
                     ],
                   },
                 ],
               },
             ]
      expect(described_class.mail.count).to eq 1
      expect(described_class.mail.first.mail_user_id).to eq 1234
    end
  end
end
