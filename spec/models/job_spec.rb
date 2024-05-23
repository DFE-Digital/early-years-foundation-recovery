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
end
