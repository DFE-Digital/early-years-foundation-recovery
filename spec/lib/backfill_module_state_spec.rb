require 'rails_helper'

RSpec.describe BackfillModuleState do
  include_context 'with events'
  
  before do
    create_event(user, 'module_content_page', Time.new(2000,01,02), 'brain-development-and-how-children-learn', 'intro')
    described_class.new(user: user).call
    
    create_event(user1, 'module_content_page', Time.new(2000,01,01), 'child-development-and-the-eyfs', 'intro')
    create_event(user1, 'module_content_page', Time.new(2000,01,03), 'child-development-and-the-eyfs', '1-3-2-6')
    create_event(user1, 'module_content_page', Time.new(2000,01,02), 'brain-development-and-how-children-learn', 'intro')
    create_event(user1, 'module_content_page', Time.new(2000,01,03), 'brain-development-and-how-children-learn', '2-3-3-5')
    described_class.new(user: user1).call
  
    create_event(user2, 'module_content_page', Time.new(2000,01,02), 'child-development-and-the-eyfs', 'intro')
    create_event(user2, 'module_content_page', Time.new(2000,01,03), 'child-development-and-the-eyfs', '1-3-2-6')
    described_class.new(user: user2).call
  end
  
  it 'calculates completion time for existing users' do
    expect(user.module_time_to_completion).to eq('brain-development-and-how-children-learn' => 0)
    expect(user1.module_time_to_completion).to eq('child-development-and-the-eyfs' => 172800, 'brain-development-and-how-children-learn' => 86400)
    expect(user2.module_time_to_completion).to eq('child-development-and-the-eyfs' => 86400)
  end
end