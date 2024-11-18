require 'rails_helper'

RSpec.describe DataAnalysis::AssessmentForLeadersAndManagers do
  let(:headers) do
    %w[
      user_id
      training_module
      score
      passed
      started_at
      completed_at
    ]
  end

  let(:rows) do
    [
      {
        user_id: user_one.id,
        training_module: 'alpha',
        score: 0.0,
        passed: false,
        started_at: '2024-01-02 00:00:00',
        completed_at: '2024-01-02 00:20:00',
      },
      {
        user_id: user_one.id,
        training_module: 'alpha',
        score: 100.0,
        passed: true,
        started_at: '2024-01-02 00:00:00',
        completed_at: '2024-01-02 00:20:00',
      },
      {
        user_id: user_two.id,
        training_module: 'alpha',
        score: 100.0,
        passed: true,
        started_at: '2024-01-02 00:00:00',
        completed_at: '2024-01-02 00:20:00',
      },
    ]
  end

  let(:user_one) { create :user, :registered, role_type: 'Manager or team leader' }
  let(:user_two) { create :user, :registered, role_type: 'Manager or team leader' }
  let(:user_three) { create :user, :registered, role_type: 'Trainee' }

  before do
    create :assessment, :failed, user: user_one, started_at: '2024-01-02 00:00:00', completed_at: '2024-01-02 00:20:00'
    create :assessment, :passed, user: user_one, started_at: '2024-01-02 00:00:00', completed_at: '2024-01-02 00:20:00'

    create :assessment, :passed, user: user_two, started_at: '2024-01-02 00:00:00', completed_at: '2024-01-02 00:20:00'

    create :assessment, :failed, user: user_three, started_at: '2024-01-02 00:00:00', completed_at: '2024-01-02 00:20:00'
  end

  it_behaves_like 'a data export model'
end
