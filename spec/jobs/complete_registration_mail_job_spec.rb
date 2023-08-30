require 'rails_helper'

RSpec.describe CompleteRegistrationMailJob do
  context 'when users have confirmed a month ago but have not completed registration' do
    before do
      skip 'Skipping until changes made for QA can be reverted'
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, :registered, confirmed_at: 1.month.ago)
      create(:user, confirmed_at: 2.months.ago)
      mail_message = instance_double(Mail::Message, deliver: nil)
      allow(NotifyMailer).to receive(:complete_registration).and_return(mail_message)
    end

    it 'emails the correct users' do
      message = 'CompleteRegistrationMailJob - users contacted: 3'
      expect { described_class.run }.to output(/#{message}/).to_stdout
    end
  end
end
