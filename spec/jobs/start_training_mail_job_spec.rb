require 'rails_helper'

RSpec.describe StartTrainingMailJob do
  context 'when users have confirmed a month ago and have completed registration but not started training' do
    before do
      create(:user, :registered, confirmed_at: 4.weeks.ago)
      create(:user, :registered, confirmed_at: 4.weeks.ago)
      create(:user, :registered, confirmed_at: 4.weeks.ago)
      create(:user, :registered, confirmed_at: 2.months.ago)
      create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 })
      mail_message = instance_double(Mail::Message, deliver: nil)
      allow(NotifyMailer).to receive(:start_training).and_return(mail_message)
    end

    it 'emails the correct users' do
      message = 'StartTrainingMailJob - users contacted: 3'
      expect { described_class.run }.to output(/#{message}/).to_stdout
    end
  end
end
