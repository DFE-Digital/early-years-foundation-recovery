require 'rails_helper'

RSpec.describe ApplicationJob do
  before do
    Que::Job.run_synchronously = true
  end

  describe '#run' do
    it 'prevents concurrent duplicates of the same class' do
      expect { described_class.run }.not_to raise_error
      create :job, job_class: described_class.name
      create :job, job_class: described_class.name
      expect { described_class.run }.to raise_error ApplicationJob::DuplicateJobError
    end
  end
end
