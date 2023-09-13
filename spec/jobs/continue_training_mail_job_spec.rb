require 'rails_helper'

RSpec.describe ContinueTrainingMailJob do
  let(:template) { :continue_training }

  let(:user) do
    create :user, :registered,
           confirmed_at: 8.weeks.ago,
           last_logged_in_at: 4.weeks.ago,
           module_time_to_completion: { alpha: 0 }
  end

  let(:user_2) do
    create :user, :registered,
           confirmed_at: 8.weeks.ago,
           last_logged_in_at: 4.weeks.ago,
           module_time_to_completion: { alpha: 0 }
  end

  let(:user_3) do
    create :user, :registered,
           confirmed_at: 8.weeks.ago,
           last_logged_in_at: nil,
           module_time_to_completion: { alpha: 0 }
  end

  let(:included) { [user] }
  let(:excluded) { [user_2] }

  # Must have started, but not completed training
  # Must be 4 weeks since their last_logged_in_at
  # `user_2` won't be included because they last logged in 2 weeks ago
  it_behaves_like 'an email prompt', nil, Training::Module.by_name(:alpha)
end
