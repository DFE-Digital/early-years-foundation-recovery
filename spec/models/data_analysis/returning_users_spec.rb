require 'rails_helper'

RSpec.describe DataAnalysis::ReturningUsers do
  let(:headers) do
    ['Weekly Returning Users',
     'Monthly Returning Users',
     'Quarterly Returning Users']
  end

  let(:rows) do
    [
      {
        weekly: 1,
        monthly: 1,
        quarterly: 1,
      },
    ]
  end

  let(:user) { create :user, :registered }

  before do
    Visit.create!(id: 1, user_id: 1, started_at: Time.zone.today.last_week)
    Visit.create!(id: 2, user_id: 1, started_at: Time.zone.today.last_week)
    Visit.create!(id: 3, user_id: 1, started_at: Time.zone.today.last_month)
    Visit.create!(id: 4, user_id: 1, started_at: Time.zone.today.last_month)
    Visit.create!(id: 5, user_id: 1, started_at: Time.zone.today.beginning_of_quarter)
    Visit.create!(id: 6, user_id: 1, started_at: Time.zone.today.beginning_of_quarter)
  end

  it_behaves_like 'a data export model'
end
