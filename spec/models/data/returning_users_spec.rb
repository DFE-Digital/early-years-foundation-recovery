require 'rails_helper'

RSpec.describe Data::ReturningUsers do
  let(:headers) do
    [
      'Weekly Returning Users',
      'Monthly Returning Users',
      'Bimonthly Returning Users',
      'Quarterly Returning Users',
    ]
  end

  let(:rows) do
    [
      {
        weekly: 1,
        monthly: 1,
        bimonthly: 1,
        quarterly: 1,
      },
    ]
  end

  let(:user) { create :user, :registered }

  before do
    Ahoy::Visit.create! id: 1, user_id: user.id, started_at: Time.zone.now
    Ahoy::Visit.create! id: 9, user_id: user.id, started_at: 1.day.ago
    Ahoy::Visit.create! id: 2, user_id: user.id, started_at: 1.week.ago
    Ahoy::Visit.create! id: 3, user_id: user.id, started_at: 2.weeks.ago
    Ahoy::Visit.create! id: 4, user_id: user.id, started_at: 1.month.ago
    Ahoy::Visit.create! id: 5, user_id: user.id, started_at: 2.months.ago
    Ahoy::Visit.create! id: 8, user_id: user.id, started_at: 3.months.ago.beginning_of_quarter
  end

  it_behaves_like 'a data export model'
end
