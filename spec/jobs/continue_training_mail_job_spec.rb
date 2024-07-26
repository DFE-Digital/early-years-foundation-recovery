require 'rails_helper'

RSpec.describe ContinueTrainingMailJob do
  include_context 'with progress'

  let(:user) { create(:user, :registered, confirmed_at: 4.weeks.ago) }

  let(:user_two) do
    create :user, :registered,
           confirmed_at: 4.weeks.ago,
           module_time_to_completion: { alpha: 0 }
  end

  let(:user_three) do
    create :user, :registered,
           confirmed_at: 4.weeks.ago,
           module_time_to_completion: { alpha: 0 }
  end

  let!(:included) { [user] }
  let!(:excluded) { [user_two, user_three] }

  # Must have started, but not completed training.
  # Must be 4 weeks since their last visit
  # `user_two` won't be included because they have a visit from 2 weeks ago
  before do
    create :visit,
           id: 9,
           visitor_token: '345',
           user_id: user.id,
           started_at: 4.weeks.ago

    create :visit,
           id: 7,
           visitor_token: '123',
           user_id: user_two.id,
           started_at: 4.weeks.ago

    create :visit,
           id: 8,
           visitor_token: '234',
           user_id: user_two.id,
           started_at: 2.weeks.ago

    create :visit,
           id: 10,
           visitor_token: '456',
           user_id: user_three.id,
           started_at: 5.weeks.ago

    # Travel to 4 weeks ago so that the module start event won't count as a recent visit
    travel_to 4.weeks.ago
    start_module(alpha)
    travel_back
  end

  it_behaves_like 'an email prompt', nil, Training::Module.by_name(:alpha)
end
