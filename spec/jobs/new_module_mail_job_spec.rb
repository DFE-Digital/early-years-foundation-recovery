require 'rails_helper'

RSpec.describe NewModuleMailJob do
  include_context 'with progress'

  let(:template) { :new_module }

  let(:included) { [user] }

  let(:excluded) do
    create_list :user, 2, :registered,
                confirmed_at: 4.weeks.ago,
                module_time_to_completion: { alpha: 1 }
  end

  # Create records for the previously released modules completed by the recipients
  # Each `module_release` must have a corresponding `release` record
  before do
    create(:release, id: 1)
    create(:module_release, release_id: 1, module_position: 1, name: 'alpha')
    create(:release, id: 2)
    create(:module_release, release_id: 1, module_position: 2, name: 'bravo')
  end

  it_behaves_like 'an email prompt', 2, Training::Module.by_name(:charlie)
end
