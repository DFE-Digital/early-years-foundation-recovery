require 'rails_helper'
require 'module_completion_existing_users'

RSpec.describe BackfillModuleState do
  include_context 'with foo'
  
  let(:test_modules) do
    [
      ['alpha', '1-3-3-4'],
      ['bravo', '1-2-2-3'],
      ['charlie', '1-1-3'],
    ]
  end

  let!(:events) do
    create_event(user1, 'module_content_page', Time.new(2000,01,01), 'alpha', 'intro')
    create_event(user1, 'module_content_page', Time.new(2000,01,03), 'alpha', '1-3-3-4')

    create_event(user2, 'module_content_page', Time.new(2000,01,02), 'alpha', 'intro')
    create_event(user2, 'module_content_page', Time.new(2000,01,03), 'alpha', '1-3-3-4')

    create_event(user1, 'module_content_page', Time.new(2000,01,02), 'bravo', 'intro')
    create_event(user1, 'module_content_page', Time.new(2000,01,03), 'bravo', '1-2-2-3')
  end

  let!(:completion_event) { described_class.new(user: user1).call }
  let!(:completion_event2) { described_class.new(user: user2).call }

  it 'calculates completion time for existing users' do
    expect(User.first.module_time_to_completion).to eq('alpha' => 172800, 'bravo' => 86400)
    expect(User.second.module_time_to_completion).to eq('alpha' => 86400)
  end
end