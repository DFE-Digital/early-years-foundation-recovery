require 'rails_helper'

RSpec.describe NewModuleMailJob do
  include_context 'with progress'

  let(:template) { :new_module }
  
  let(:included) { [user] }

  let(:excluded) do
    create_list :user, 2, :registered, confirmed_at: 4.weeks.ago
  end

  # Recipients must have completed all available modules - in this case, alpha and bravo
  before do
    # Create records for the previously released modules completed by the recipients
    # Each `module_release` must have a corresponding `release` record
    create(:release, id: 1)
    create(:module_release, release_id: 1, module_position: 1, name: 'alpha')
    create(:release, id: 2)
    create(:module_release, release_id: 1, module_position: 2, name: 'bravo')

    # This will complete the alpha and bravo modules for `user`
    complete_module(alpha, 1.minute)
    complete_module(bravo, 1.minute)
  end

  it_behaves_like 'an email prompt', 2, Training::Module.by_name(:charlie)
end
