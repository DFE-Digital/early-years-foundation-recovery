require 'rails_helper'

RSpec.describe ModuleTimeToComplete do
  include_context 'with progress'

  let(:module_name) { alpha.name }

  subject(:completion_time) { described_class.new(user: user, training_module_id: module_name) }
  let(:user) { create(:user, :confirmed) }

  before do
    # fake alpha event
    # Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,01),
    #   properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
    # Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,03),
    #   properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
    
    #   # fake bravo event
    # Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,02),
    #   properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!
    # Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,05),
    #   properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!
  end
    
  describe '#update_time' do
    it 'returns a hash containing time to complete alpha' do
      result = completion_time.update_time
      expect(result).to include('alpha' => 172800)
    end

    it 'returns a hash containing time to complete bravo' do
      result = completion_time.update_time
      expect(result).to include('bravo' => 259200)
    end
  end

  it 'works' do
    # fake alpha event
    Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,01),
    properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,03),
    properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
    # binding.pry

    module_name = 'alpha'
    completion_time.update_time
    expect(user.module_time_to_completion).to include('alpha' => 172800)

    # fake bravo event
    Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,02),
    properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,05),
    properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!

    # binding.pry
    module_name = 'bravo'
    completion_time.update_time
    expect(user.module_time_to_completion).to include('bravo' => 259200)
  end
end
