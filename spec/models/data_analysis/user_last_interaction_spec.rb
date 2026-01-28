require 'rails_helper'

RSpec.describe DataAnalysis::UserLastInteraction do
  let(:headers) do
    [
      'User ID',
      'Registration Complete',
      'Last Interaction At',
    ]
  end

  let(:now) { Time.zone.parse('2024-01-01 12:00') }

  let!(:user_recent) { create :user, :registered }
  let!(:user_old) { create :user, :registered }

  let(:rows) do
    [
      {
        user_id: user_recent.id,
        registration_complete: user_recent.registration_complete,
        last_interaction_at: now - 1.day,
      },
    ]
  end

  before do
    travel_to(now)

    create :response, user: user_recent, created_at: now - 2.days
    create :note, user: user_recent, updated_at: now - 1.day

    create :assessment, user: user_old, completed_at: now - (DataAnalysis::UserLastInteraction::WINDOW_DAYS + 1).days
  end

  after do
    travel_back
  end

  it_behaves_like 'a data export model'
end
