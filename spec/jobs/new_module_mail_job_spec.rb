require 'rails_helper'

RSpec.describe NewModuleMailJob do
  let!(:included) do
    create_list :user, 1, :registered
  end

  let!(:excluded) do
    create_list :user, 2, :closed
  end

  let(:job_vars) { [2] }

  # Create records for the previously released modules completed by the recipients
  # Each `module_release` must have a corresponding `release` record
  before do
    create :release, id: 1, name: 'first', time: '2023-03-16 13:00:00'
    create :module_release, release_id: 1, module_position: 1, name: 'alpha', contentful_entry_id: '6EczqUOpieKis8imYPc6mG'

    Training::Module.reset_cache_key!

    create :release, id: 2, name: 'second'
    create :module_release, release_id: 1, module_position: 2, name: 'bravo', contentful_entry_id: '4u49zTRJzYAWsBI6CitwN4'

    modules = Training::Module.live

    modules.each do |mod|
      allow(mod).to receive(:release_email_requested?)
        .and_return(mod.name == 'charlie')
    end

    allow(Training::Module).to receive(:live).and_return(modules)
  end

  it_behaves_like 'an email prompt', 2, Training::Module.by_name(:charlie) do
    let(:recipient_args) { [Training::Module.by_name(:charlie).id] }
  end

  it 'resets cache' do
    expect(Training::Module.cache_key).to eq '16-03-2023-13-00'
    freeze_time do
      described_class.run(*job_vars)
      expect(Training::Module.cache_key).to eq Time.zone.now.strftime('%d-%m-%Y-%H-%M')
    end
  end

  describe 'release email controls' do
    let(:mod) do
      Training::Module.live.find { |training_module| training_module.name == 'charlie' }
    end

    def release_record
      ModuleRelease.find_by!(contentful_entry_id: mod.id)
    end

    it 'records publication without sending an email when the flag is off' do
      allow(mod).to receive(:release_email_requested?).and_return(false)
      expect(NotifyMailer).not_to receive(:new_module)

      expect {
        described_class.run(*job_vars)
      }.to change {
        ModuleRelease.where(contentful_entry_id: mod.id).count
      }.from(0).to(1)

      expect(release_record.first_published_at).to eq Release.find(2).time
      expect(release_record.release_email_queued_at).to be_nil
    end

    it 'sends an email and records the timestamp when the flag is on' do
      expect(NotifyMailer)
        .to receive(:new_module)
        .with(included.first, mod)
        .once
        .and_call_original

      freeze_time do
        described_class.run(*job_vars)

        expect(release_record.release_email_queued_at).to eq Time.current
      end
    end

    it 'does not announce the module again on a later run' do
      described_class.run(*job_vars)
      original_timestamp = release_record.release_email_queued_at
      expect(original_timestamp).to be_present

      expect(NotifyMailer).not_to receive(:new_module)

      travel_to 1.day.from_now do
        described_class.run(*job_vars)

        expect(release_record.release_email_queued_at).to eq original_timestamp
      end
    end

    it 'does not announce or record the module again after its position changes' do
      described_class.run(*job_vars)
      original_release = release_record
      expect(original_release.release_email_queued_at).to be_present

      allow(mod).to receive(:position).and_return(mod.position + 10)
      expect(NotifyMailer).not_to receive(:new_module)

      expect {
        described_class.run(*job_vars)
      }.not_to change(ModuleRelease, :count)

      expect(release_record.id).to eq original_release.id
      expect(release_record.first_published_at)
        .to eq original_release.first_published_at
      expect(release_record.release_email_queued_at)
        .to eq original_release.release_email_queued_at
    end

    it 'rolls back queued emails when processing fails' do
      create :user, :registered

      allow(described_class).to receive(:enqueue?).and_return(true)

      original_adapter = ActionMailer::MailDeliveryJob.queue_adapter
      ActionMailer::MailDeliveryJob.queue_adapter = :que

      calls = 0

      allow(NotifyMailer).to receive(:new_module).and_wrap_original do |original, *args|
        calls += 1
        raise 'Simulated failure' if calls == 2

        original.call(*args)
      end

      expect {
        described_class.run(*job_vars)
      }.to raise_error(RuntimeError, 'Simulated failure')

      expect(calls).to eq 2
      expect(release_record.release_email_queued_at).to be_nil
      expect(Job.module_release_mail(mod.id)).to be_empty
    ensure
      ActionMailer::MailDeliveryJob.queue_adapter = original_adapter
    end
  end
end
