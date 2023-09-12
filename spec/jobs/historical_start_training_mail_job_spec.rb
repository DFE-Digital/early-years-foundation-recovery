require 'rails_helper'

RSpec.describe HistoricalStartTrainingMailJob do
  let(:template) { :start_training }

  # Must have confirmed email more than 4 weeks before nudge email launch date, completed registration and not have started training
  let(:included) do
    create_list :user, 3, :registered, confirmed_at: Time.zone.local(2023, 1, 1)
  end

  let(:excluded) do
    [
      create(:user, :registered, confirmed_at: 2.months.ago),
      create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { alpha: 0 }),
      create(:user, :registered, confirmed_at: 4.weeks.ago),
    ]
  end

  it_behaves_like 'an email prompt'
end
