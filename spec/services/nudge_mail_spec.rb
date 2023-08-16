require 'rails_helper'

RSpec.describe NudgeMail do
  subject(:nudge_mail) { described_class.new }

  context 'when users have confirmed a month ago but have not completed registration' do
    let!(:user_1) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 1.month.ago) }
    let!(:user_5) { create(:user, confirmed_at: 2.months.ago) }

    before do
      allow(NotifyMailer).to receive(:complete_registration)
    end

    it 'emails the correct users' do
      expected = [user_1, user_2, user_3]
      excluded = [user_4, user_5]
      expect(nudge_mail.complete_registration).to send_expected_emails(
        mailer: NotifyMailer,
        mailer_method: :complete_registration,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end

  context 'when users have confirmed a month ago and have completed registration but not started training' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 2.months.ago) }
    let!(:user_5) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }

    before do
      allow(NotifyMailer).to receive(:start_training)
    end

    it 'emails the correct users' do
      expected = [user_1, user_2, user_3]
      excluded = [user_4, user_5]
      expect(nudge_mail.start_training).to send_expected_emails(
        mailer: NotifyMailer,
        mailer_method: :start_training,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end

  context 'when users have confirmed a month ago and have completed registration and started training but not completed training' do
    include_context 'with progress'

    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1 }) }

    before do
      user.update!(module_time_to_completion: { "alpha": 0 }, confirmed_at: 4.weeks.ago)
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

      Ahoy::Visit.new(
        id: 9,
        visitor_token: '345',
        user_id: user.id,
        started_at: 4.weeks.ago,
      ).save!
      travel_to 4.weeks.ago
      start_module(alpha)
      travel_back

      allow(NotifyMailer).to receive(:continue_training)
    end

    it 'emails the correct users' do
      expected = [user]
      excluded = [user_2, user_3]
      expect(nudge_mail.continue_training).to send_expected_emails(
        mailer: NotifyMailer,
        mailer_method: :continue_training,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end

  context 'when users have completed all available modules and a new module is released' do
    include_context 'with progress'
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1, "beta": 0 }) }

    before do
      complete_module(alpha)
      complete_module(bravo)
      user.update!(module_time_to_completion: { "alpha": 1, "beta": 1 }, confirmed_at: 4.weeks.ago)
      PreviouslyPublishedModule.create!(module_position: 1, name: 'alpha', first_published_at: Time.zone.now).save!

      allow(NotifyMailer).to receive(:new_module)
    end

    it 'emails the correct users' do
      expected = [user]
      excluded = [user_2]
      expect(nudge_mail.new_module(charlie)).to send_expected_emails(
        mailer: NotifyMailer,
        mailer_method: :new_module,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end
end
