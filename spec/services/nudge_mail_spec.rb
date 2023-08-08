require 'rails_helper'

RSpec.describe NudgeMail do
  subject(:nudge_mail) { described_class.new }

  context 'when users are a month old but have not completed registration' do
    let!(:user_1) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 1.month.ago) }
    let!(:user_5) { create(:user, confirmed_at: 2.months.ago) }
    let(:notify_mailer) { class_double(NotifyMailer).as_stubbed_const }

    before do
      allow(NotifyMailer).to receive(:complete_registration)
    end

    it 'The notify mailer is called with the correct users' do
      nudge_mail.call
      expect(NotifyMailer).to have_received(:complete_registration).with(user_1).once
      expect(NotifyMailer).to have_received(:complete_registration).with(user_2).once
      expect(NotifyMailer).to have_received(:complete_registration).with(user_3).once
      expect(NotifyMailer).not_to have_received(:complete_registration).with(user_4)
      expect(NotifyMailer).not_to have_received(:complete_registration).with(user_5)
    end
  end

  context 'when users are a month old and have completed registration but not started training' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 2.months.ago) }
    let!(:user_5) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }

    before do
      allow(NotifyMailer).to receive(:start_training)
    end

    it 'The notify mailer is called with the correct users' do
      nudge_mail.call
      expect(NotifyMailer).to have_received(:start_training).with(user_1).once
      expect(NotifyMailer).to have_received(:start_training).with(user_2).once
      expect(NotifyMailer).to have_received(:start_training).with(user_3).once
      expect(NotifyMailer).not_to have_received(:start_training).with(user_4)
      expect(NotifyMailer).not_to have_received(:start_training).with(user_5)
    end
  end

  context 'when users are a month old and have completed registration and started training but not completed training' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_4) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1 }) }
    let!(:user_5) { create(:user, :registered, confirmed_at: 8.weeks.ago, module_time_to_completion: { "alpha": 2 }) }

    before do
      Ahoy::Visit.new(
        id: 1,
        visitor_token: '123',
        user_id: user_1.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 2,
        visitor_token: '234',
        user_id: user_1.id,
        started_at: 2.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 3,
        visitor_token: '345',
        user_id: user_2.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 4,
        visitor_token: '456',
        user_id: user_3.id,
        started_at: 4.weeks.ago,
      ).save!

      allow(NotifyMailer).to receive(:continue_training)
    end

    it 'The notify mailer is called with the correct users' do
      nudge_mail.call
      expect(NotifyMailer).to have_received(:continue_training).with(user_2, TrainingModule.find_by(name: 'alpha')).once
      expect(NotifyMailer).to have_received(:continue_training).with(user_3, TrainingModule.find_by(name: 'alpha')).once
      expect(NotifyMailer).not_to have_received(:continue_training).with(user_1, TrainingModule.find_by(name: 'alpha'))
      expect(NotifyMailer).not_to have_received(:continue_training).with(user_4, TrainingModule.find_by(name: 'alpha'))
      expect(NotifyMailer).not_to have_received(:continue_training).with(user_5, TrainingModule.find_by(name: 'alpha'))
    end
  end
end