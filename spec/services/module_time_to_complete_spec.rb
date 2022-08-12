require 'rails_helper'

RSpec.describe ModuleTimeToComplete do
  include_context 'with progress'

  let(:module_name) { alpha.name }

  subject(:completion_time) { described_class.new(user: user, training_module_id: module_name) }
  let(:user) { create(:user, :confirmed) }

  let(:alpha_event) do
    Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,01),
      properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,03),
      properties: {training_module_id: 'alpha'}, visit: Ahoy::Visit.new()).save!
  end

  let(:bravo_event) do
    Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,02),
      properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!
    Ahoy::Event.new(user_id: user.id, name: 'module_complete', time: Time.new(2000,01,05),
      properties: {training_module_id: 'bravo'}, visit: Ahoy::Visit.new()).save!
  end

  let(:charlie_event) do
    Ahoy::Event.new(user_id: user.id, name: 'module_start', time: Time.new(2000,01,04),
      properties: {training_module_id: 'charlie'}, visit: Ahoy::Visit.new()).save!
  end
  
  before do
    alpha_event
  end
    
  describe '#update_time' do
    it 'returns a hash containing time to complete alpha' do
      result = completion_time.update_time(module_name)
      expect(result).to include('alpha' => 172800)
    end
  end

  before do
    alpha_event
    bravo_event
  end
    
  describe '#update_time' do
    it 'returns a hash containing time to complete alpha and bravo' do
      result = completion_time.update_time(module_name)
      module_name = 'bravo'
      result = completion_time.update_time(module_name)
      expect(result).to include('alpha' => 172800, 'bravo' => 259200)
    end
  end

  before do
    alpha_event
    bravo_event
    charlie_event
  end
    
  describe '#update_time' do
    it 'returns a hash containing time to complete alpha, bravo and charlie' do
      result = completion_time.update_time(module_name)
      module_name = 'bravo'
      result = completion_time.update_time(module_name)
      module_name = 'charlie'
      result = completion_time.update_time(module_name)
      expect(result).to include('alpha' => 172800, 'bravo' => 259200, 'charlie' => 0)
    end
  end
end
