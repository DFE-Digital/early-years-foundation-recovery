require 'rails_helper'
require 'module_completion_existing_users'

RSpec.describe ModuleCompletionExistingUsers do
  include_context 'with progress'

  let(:module_name) { alpha.name }

  let(:user1) { create(:user, :completed) }
  let(:user2) { create(:user, :completed) }
  
  let(:test_modules) do
    [
      ['alpha', 'intro', '1-3-3-4'],
      ['bravo', 'intro', '1-2-2-3'],
      ['charlie', 'intro', '1-1-3'],
    ]
  end

  let(:events) do
    Ahoy::Event.new(user: user1, name: 'module_content_page', time: Time.new(2000,01,01),
      properties: {training_module_id: 'alpha', id: 'intro'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user: user1, name: 'module_content_page', time: Time.new(2000,01,03),
      properties: {training_module_id: 'alpha', id: '1-3-3-4'}, visit: Ahoy::Visit.new()).save!

    Ahoy::Event.new(user: user2, name: 'module_content_page', time: Time.new(2000,01,02),
      properties: {training_module_id: 'alpha', id: 'intro'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user: user2, name: 'module_content_page', time: Time.new(2000,01,03),
      properties: {training_module_id: 'alpha', id: '1-3-3-4'}, visit: Ahoy::Visit.new()).save!

    Ahoy::Event.new(user: user1, name: 'module_content_page', time: Time.new(2000,01,02),
      properties: {training_module_id: 'bravo', id: 'intro'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user: user1, name: 'module_content_page', time: Time.new(2000,01,03),
      properties: {training_module_id: 'bravo', id: '1-2-2-3'}, visit: Ahoy::Visit.new()).save!
  end

  let(:completion_event) { described_class.new.calculate_completion_time(test_modules) }

  it 'calculates completion time for existing users' do
    events
    completion_event
    expect(User.first.module_time_to_completion).to eq 'alpha' => 172800, 'bravo' => 86400
    expect(User.second.module_time_to_completion).to eq 'alpha' => 86400
  end
end