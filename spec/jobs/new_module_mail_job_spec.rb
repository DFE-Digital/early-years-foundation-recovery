require 'rails_helper'

RSpec.describe NewModuleMailJob do
  context 'when users have completed all available modules and a new module is released' do
    include_context 'with progress'
    let(:release_1) { create(:release) }
    let(:release_2) { create(:release) }

    before do
      create(:user, :registered, confirmed_at: 4.weeks.ago)
      complete_module(alpha, 1.minute)
      complete_module(bravo, 1.minute)

      create(:user, :registered, confirmed_at: 4.weeks.ago)
      create(:module_release, release_id: release_1.id, module_position: 1, name: 'alpha')
      create(:module_release, release_id: release_1.id, module_position: 2, name: 'bravo')
      mail_message = instance_double(Mail::Message, deliver: nil)
      allow(NotifyMailer).to receive(:new_module).and_return(mail_message)
    end

    it 'emails the correct users' do
      message = 'NewModuleMailJob - users contacted: 1'
      expect { described_class.run(release_2.id) }.to output(/#{message}/).to_stdout
    end
  end
end
