require 'rails_helper'

RSpec.describe ModuleTimeToComplete do
  include_context 'with progress'

  let(:module_name) { alpha.name }
  let(:user) { create(:user, :completed) }

  subject(:completion_time) { described_class.new(user: user) }

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

  let(:user_completion_time) { user.module_time_to_completion }
  
  describe '#update_time' do
    context 'when no modules have been taken'
      it 'returns empty hash' do
        completion_time.update_time
        expect(user_completion_time).to eq Hash.new
      end
    end

    context 'when alpha has been completed' do
      before do
        alpha_event
      end

      it 'returns hash containing time to complete alpha' do
        completion_time.update_time
        expect(user_completion_time).to eq('alpha' => 172800)
      end

    context 'when bravo has been completed' do
      before do
        alpha_event
        bravo_event
      end
    
      it 'returns hash containing time to complete alpha and bravo' do
        completion_time.update_time
        expect(user_completion_time).to eq('alpha' => 172800, 'bravo' => 259200)
      end
    end

    context 'when charlie has been started' do
      before do
        alpha_event
        bravo_event
        charlie_event
      end
  
      it 'returns hash containing time to complete alpha and bravo, charlie as a zero' do
        completion_time.update_time
        expect(user_completion_time).to eq('alpha' => 172800, 'bravo' => 259200, 'charlie' => 0)
      end
    end
  end
end
