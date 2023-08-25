require 'rails_helper'

RSpec.describe ContinueTrainingMailJob do
  context 'when users have confirmed a month ago and have completed registration and started training but not completed training' do
    include_context 'with progress'

    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1 }) }

    before do
      skip 'wip - try testing recipients method?'
      user.update!(confirmed_at: 4.weeks.ago)

      Ahoy::Visit.new(
        id: 9,
        visitor_token: '345',
        user_id: user.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 7,
        visitor_token: '123',
        user_id: user_2.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 8,
        visitor_token: '234',
        user_id: user_2.id,
        started_at: 2.weeks.ago,
      ).save!

      travel_to 4.weeks.ago
      start_module(alpha)
      travel_back

      allow(NotifyMailer).to receive(:continue_training)
    end

    it 'emails the correct users' do
      expected = [user]
      excluded = [user_2, user_3]
      expect(described_class.run).to send_expected_emails(
        mailer_method: :continue_training,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end
end
