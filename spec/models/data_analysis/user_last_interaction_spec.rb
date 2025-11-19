require 'rails_helper'

RSpec.describe DataAnalysis::UserLastInteraction do
  let(:headers) do
    [
      'User ID',
      'Email',
      'Registration Complete',
      'Last Interaction At',
    ]
  end

  let(:now) { Time.zone.parse('2024-01-01 12:00') }

  let!(:user_recent) { create :user, :registered, email: 'recent@example.com' }
  let!(:user_old) { create :user, :registered, email: 'old@example.com' }

  let(:rows) do
    [
      {
        user_id: user_recent.id,
        email: 'recent@example.com',
        registration_complete: user_recent.registration_complete,
        last_interaction_at: now - 1.day,
      },
    ]
  end

  before do
    travel_to(now)

    create :event, user: user_recent, time: now - 2.days
    create :event, user: user_recent, time: now - 1.day

    create :event, user: user_old, time: now - 30.days
  end

  after do
    travel_back
  end

  it_behaves_like 'a data export model'
end
