require 'rails_helper'

RSpec.describe DropOffSurveyMailJob do
  let!(:included) do
    [
      create(:user, :registered, created_at: 2.weeks.ago),
      create(:user, :registered, created_at: 1.month.ago),
    ]
  end

  let!(:excluded) do
    [
      create(:user, :registered, created_at: 1.week.ago),
      create(:user, :registered, created_at: 3.weeks.ago),
      create(:user, :registered, created_at: 2.weeks.ago,
                                 training_emails: false),
    ]
  end

  before do
    create :user_module_progress,
           user: included.second,
           started_at: 3.weeks.ago,
           updated_at: 2.weeks.ago
  end

  it 'excludes ineligible users' do
    expect(described_class.recipients).not_to include(*excluded)
  end

  it_behaves_like 'an email prompt'

  describe '#run' do
    let(:user) { included.second }

    let(:message) do
      instance_double(
        ActionMailer::MessageDelivery,
        deliver_now: true,
        deliver_later: true,
      )
    end

    before do
      create :module_release,
             name: 'alpha',
             first_published_at: 1.month.ago

      user.user_module_progress.find_by!(module_name: 'alpha').update!(
        completed_at: 2.weeks.ago,
        updated_at: 2.weeks.ago,
      )

      allow(NotifyMailer).to receive(:drop_off_survey).and_return(message)
    end

    context 'when all modules available at the last activity were completed' do
      it 'does not send the survey' do
        described_class.run

        expect(NotifyMailer).not_to have_received(:drop_off_survey).with(user)
      end
    end

    context 'when some available modules remain incomplete' do
      before do
        create :module_release,
               name: 'beta',
               module_position: 2,
               first_published_at: 1.month.ago
      end

      it 'sends the survey' do
        described_class.run

        expect(NotifyMailer).to have_received(:drop_off_survey).with(user).once
      end
    end

    context 'when a new module was released after completing all available modules' do
      before do
        create :module_release,
               name: 'beta',
               module_position: 2,
               first_published_at: 1.week.ago
      end

      it 'does not send the survey' do
        described_class.run

        expect(NotifyMailer).not_to have_received(:drop_off_survey).with(user)
      end
    end
  end
end
