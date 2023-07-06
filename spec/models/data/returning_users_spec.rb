require 'rails_helper'

RSpec.describe Data::ReturningUsers do
  let!(:user_1) { create(:user, :registered, :agency_setting, role_type: 'childminder') }

  let(:headers) do
    ['Weekly Returning Users', 'Monthly Returning Users', '2 Monthly Returning Users', 'Quarterly Returning Users']
  end

  let(:rows) do
    [
      {
        weekly_returning_users: 1,
        monthly_returning_users: 1,
        two_monthly_returning_users: 1,
        quarterly_returning_users: 1,
      },
    ]
  end

  before do
    Ahoy::Visit.create!(id: 1, user_id: user_1.id, started_at: Time.zone.now)
    Ahoy::Visit.create!(id: 2, user_id: user_1.id, started_at: 1.week.ago)
    Ahoy::Visit.create!(id: 3, user_id: user_1.id, started_at: 2.weeks.ago)
    Ahoy::Visit.create!(id: 4, user_id: user_1.id, started_at: 1.month.ago)
    Ahoy::Visit.create!(id: 5, user_id: user_1.id, started_at: 2.months.ago)
    Ahoy::Visit.create!(id: 6, user_id: user_1.id, started_at: 4.months.ago)
    Ahoy::Visit.create!(id: 7, user_id: user_1.id, started_at: 13.weeks.ago)
    Ahoy::Visit.create!(id: 8, user_id: user_1.id, started_at: 10.weeks.ago)
  end

  it_behaves_like('a data export model')
end
