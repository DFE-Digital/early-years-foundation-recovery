require 'rails_helper'
require 'backfill_module_events'

RSpec.describe BackfillModuleEvents do
  include_context 'with events'

  before do
    create_event(user, 'module_content_page', Time.zone.local(2000, 0o1, 0o1), 'child-development-and-the-eyfs', 'intro')
    create_event(user, 'module_content_page', Time.zone.local(2000, 0o1, 0o3), 'child-development-and-the-eyfs', '1-3-2-6')
    create_event(user, 'module_content_page', Time.zone.local(2000, 0o1, 0o2), 'brain-development-and-how-children-learn', 'intro')
  end

  it 'creates missing module_start and module_complete events' do
    # original events
    expect(Ahoy::Event.count).to be 3

    # calculate ttc from those events
    expect(user.module_time_to_completion).to be_empty
    BackfillModuleState.new(user: user).call
    expect(user.module_time_to_completion).not_to be_empty

    original_event = Ahoy::Event.last

    # clone
    described_class.new(user: user).call
    expect(Ahoy::Event.count).to be 6

    clone_event = Ahoy::Event.last

    # cloned and amended attributes
    expect(clone_event.time).to eq original_event.time
    expect(clone_event.name).to eq 'module_start'
    expect(clone_event.properties['clone']).to be true
  end
end
