require 'rails_helper'

RSpec.describe StartTrainingMailJob do
  context 'when users have confirmed a month ago and have completed registration but not started training' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 2.months.ago) }
    let!(:user_5) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }

    before do
      skip 'wip - try testing recipients method?'
      allow(NotifyMailer).to receive(:start_training)
    end

    it 'emails the correct users' do
      expected = [user_1, user_2, user_3]
      excluded = [user_4, user_5]
      expect(described_class.run).to send_expected_emails(
        mailer_method: :start_training,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end
end
