require 'rails_helper'

RSpec.describe NewModuleMailJob do
  let!(:included) do
    create_list :user, 1, :registered
  end

  let!(:excluded) do
    create_list :user, 2, :closed
  end

  let(:job_vars) { [2] }

  # Create records for the previously released modules completed by the recipients
  # Each `module_release` must have a corresponding `release` record
  before do
    create :release, id: 1, name: 'first', time: '2023-03-16 13:00:00'
    create :module_release, release_id: 1, module_position: 1, name: 'alpha'

    Training::Module.reset_cache_key!

    create :release, id: 2, name: 'second'
    create :module_release, release_id: 1, module_position: 2, name: 'bravo'
  end

  it_behaves_like 'an email prompt', 2, Training::Module.by_name(:charlie)

  it 'resets cache' do
    expect(Training::Module.cache_key).to eq '16-03-2023-13-00'
    freeze_time do
      described_class.run(*job_vars)
      expect(Training::Module.cache_key).to eq Time.zone.now.strftime('%d-%m-%Y-%H-%M')
    end
  end
end
