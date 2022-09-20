require 'rails_helper'

RSpec.describe BackfillModuleState do
  include_context 'with events'

  before do
    create_event(user, 'module_content_page', Time.zone.local(2000, 0o1, 0o2), 'brain-development-and-how-children-learn', 'intro')
    described_class.new(user: user).call

    create_event(user1, 'module_content_page', Time.zone.local(2000, 0o1, 0o1), 'child-development-and-the-eyfs', 'intro')
    create_event(user1, 'module_content_page', Time.zone.local(2000, 0o1, 0o3), 'child-development-and-the-eyfs', '1-3-3')
    create_event(user1, 'module_content_page', Time.zone.local(2000, 0o1, 0o2), 'brain-development-and-how-children-learn', 'intro')
    create_event(user1, 'module_content_page', Time.zone.local(2000, 0o1, 0o3), 'brain-development-and-how-children-learn', '2-3-4')
    described_class.new(user: user1).call

    create_event(user2, 'module_content_page', Time.zone.local(2000, 0o1, 0o2), 'child-development-and-the-eyfs', 'intro')
    create_event(user2, 'module_content_page', Time.zone.local(2000, 0o1, 0o3), 'child-development-and-the-eyfs', '1-3-3')
    described_class.new(user: user2).call
  end

  it 'calculates completion time for existing users' do
    expect(user.module_time_to_completion).to eq('brain-development-and-how-children-learn' => 0)
    expect(user1.module_time_to_completion).to eq('child-development-and-the-eyfs' => 172_800, 'brain-development-and-how-children-learn' => 86_400)
    expect(user2.module_time_to_completion).to eq('child-development-and-the-eyfs' => 86_400)
  end
end