require 'rails_helper'

RSpec.describe ApplicationJob do
  before do
    Que::Job.run_synchronously = true
  end

  describe '#run' do
    it 'runs within a Que consumer span' do
      expect(ApplicationInsightsTelemetry).to receive(:with_span).with(
        'que.process ApplicationJob',
        {
          'messaging.system' => 'que',
          'messaging.operation.type' => 'process',
          'code.function.name' => 'ApplicationJob',
        },
        kind: :consumer,
      ).and_yield

      described_class.run
    end

    it 'prevents concurrent duplicates of the same class' do
      expect { described_class.run }.not_to raise_error
      create :job, job_class: described_class.name # Job to run
      create :job, job_class: described_class.name # Duplicate
      expect { described_class.run }.to raise_error ApplicationJob::DuplicateJobError
    end
  end
end
