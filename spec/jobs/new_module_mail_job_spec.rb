require 'rails_helper'

RSpec.describe NewModuleMailJob do
  context 'when users have completed all available modules and a new module is released' do
    let(:user) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1, "bravo": 1 }) }
    let(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:release_1) { create(:release) }
    let!(:release_2) { create(:release) }

    before do
      skip 'wip - try testing recipients method?'
      create(:module_release, release_id: release_1.id, module_position: 1, name: 'alpha')
      create(:module_release, release_id: release_1.id, module_position: 2, name: 'bravo')
      # complete_module(alpha)
      # complete_module(bravo)
      mail_message = instance_double(Mail::Message, deliver: nil)
      allow(NotifyMailer).to receive(:new_module).and_return(mail_message)
    end

    it 'emails the correct users' do
      message = 'NewModuleMailJob contacted 1 users'
      expect { described_class.run(release_2.id) }.to output(message).to_stdout
    end
  end
end
