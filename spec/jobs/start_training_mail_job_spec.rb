require 'rails_helper'

RSpec.describe StartTrainingMailJob do
  # Must have confirmed email 4 weeks ago, completed registration and not have started training
  let!(:included) do
    create_list :user, 3, :registered, confirmed_at: 4.weeks.ago
  end

  let!(:excluded) do
    [
      create(:user, :registered, confirmed_at: 2.months.ago),
      create(:user, :registered, confirmed_at: 4.weeks.ago),
    ]
  end

  before do
    create :event, name: 'module_start', user: excluded.last
  end

  it_behaves_like 'an email prompt'
end
