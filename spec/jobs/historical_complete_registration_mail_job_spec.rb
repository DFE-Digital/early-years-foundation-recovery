require 'rails_helper'

RSpec.describe HistoricalCompleteRegistrationMailJob do
  let(:template) { :complete_registration }

  # Must have confirmed email more than 4 weeks before nudge email launch date and not have completed registration
  let(:included) do
    create_list :user, 3, confirmed_at: Time.zone.local(2023, 1, 1)
  end

  let(:excluded) do
    [
      create(:user, :registered, confirmed_at: 4.weeks.ago),
      create(:user, confirmed_at: 2.months.ago),
      create(:user, confirmed_at: 4.weeks.ago),
    ]
  end

  it_behaves_like 'an email prompt'
end
