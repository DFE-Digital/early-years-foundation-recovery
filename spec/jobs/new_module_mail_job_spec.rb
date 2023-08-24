require 'rails_helper'

RSpec.describe NewModuleMailJob do
  context 'when users have completed all available modules and a new module is released' do
    # TODO: uncomment this before merging
    let(:user) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1, "bravo": 1 }) }
    let(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:release_1) { create(:release) }
    let!(:release_2) { create(:release) }

    before do
      create(:module_release, release_id: release_1.id, module_position: 1, name: 'alpha')
      create(:module_release, release_id: release_1.id, module_position: 2, name: 'bravo')

      allow(NotifyMailer).to receive(:new_module)
    end

    it 'emails the correct users' do
      expected = [user, user_2]
      # excluded = [user_2]
      excluded = []
      expect(described_class.run(release_2.id)).to send_expected_emails(
        mailer_method: :new_module,
        expected_users: expected,
        excluded_users: excluded,
      )
    end
  end
end
