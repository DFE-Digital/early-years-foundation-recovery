require 'rails_helper'

RSpec.describe StartTrainingMailJob do
  let(:template) { :start_training }

  let!(:included) do
    create_list :user, 3, :registered, confirmed_at: 4.weeks.ago
  end

  let!(:excluded) do
    [
      create(:user, :registered, confirmed_at: 2.months.ago),
      create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { alpha: 0 }),
    ]
  end

  it_behaves_like 'an email prompt'
end
