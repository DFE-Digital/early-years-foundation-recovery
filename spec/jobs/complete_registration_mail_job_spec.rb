require 'rails_helper'

RSpec.describe CompleteRegistrationMailJob do
  context 'when users have confirmed a month ago but have not completed registration' do
    let!(:user_1) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 1.month.ago) }
    #TODO: uncomment this before merging
    # let!(:user_5) { create(:user, confirmed_at: 2.months.ago) }

    before do
      allow(NotifyMailer).to receive(:complete_registration)
    end

    it 'emails the correct users' do
      expected = [user_1, user_2, user_3]
      # excluded = [user_4, user_5]
      excluded = [user_4]
      expect(described_class.run).to send_expected_emails(
        mailer_method: :complete_registration,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end
end
