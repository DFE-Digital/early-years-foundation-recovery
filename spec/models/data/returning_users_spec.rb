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
    Ahoy::Visit.new(id: 1, user_id: user_1.id, started_at: 9.weeks.ago).save!
    Ahoy::Visit.new(id: 2, user_id: user_1.id, started_at: 8.weeks.ago).save!
    Ahoy::Visit.new(id: 3, user_id: user_1.id, started_at: 7.weeks.ago).save!
    Ahoy::Visit.new(id: 4, user_id: user_1.id, started_at: 6.weeks.ago).save!
    Ahoy::Visit.new(id: 5, user_id: user_1.id, started_at: 5.weeks.ago).save!
    Ahoy::Visit.new(id: 6, user_id: user_1.id, started_at: 4.weeks.ago).save!
    Ahoy::Visit.new(id: 7, user_id: user_1.id, started_at: 3.weeks.ago).save!
    Ahoy::Visit.new(id: 8, user_id: user_1.id, started_at: 2.weeks.ago).save!
    Ahoy::Visit.new(id: 9, user_id: user_1.id, started_at: 1.week.ago).save!
    Ahoy::Visit.new(id: 10, user_id: user_1.id, started_at: 1.day.ago).save!
    Ahoy::Visit.new(id: 11, user_id: user_1.id, started_at: 10.weeks.ago).save!
    Ahoy::Visit.new(id: 12, user_id: user_1.id, started_at: 11.weeks.ago).save!
    Ahoy::Visit.new(id: 13, user_id: user_1.id, started_at: 12.weeks.ago).save!
    Ahoy::Visit.new(id: 14, user_id: user_1.id, started_at: 13.weeks.ago).save!
  end

  it_behaves_like('a data export model')
end
