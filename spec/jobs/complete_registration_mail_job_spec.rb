require 'rails_helper'

RSpec.describe CompleteRegistrationMailJob do
  context 'when users have confirmed a month ago but have not completed registration' do
    subject(:job) { described_class.run }

    let(:message) { 'CompleteRegistrationMailJob - users contacted: 3' }

    before do
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, confirmed_at: 4.weeks.ago)
      create(:user, :registered, confirmed_at: 1.month.ago)
      create(:user, confirmed_at: 2.months.ago)
      mail_message = instance_double(Mail::Message, deliver: nil)
      allow(NotifyMailer).to receive(:complete_registration).and_return(mail_message)
    end

    it_behaves_like 'a mail job'
  end
end
