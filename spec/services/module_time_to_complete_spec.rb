require 'rails_helper'

RSpec.describe ModuleTimeToComplete do
  include_context 'with foo'

  subject(:completion_time) { described_class.new(user: user) }

  let(:alpha_start_and_complete) do
    create_event(user, 'module_start', Time.new(2000,01,01), 'alpha')
    create_event(user, 'module_complete', Time.new(2000,01,03), 'alpha')
  end

  let(:bravo_start_and_complete) do
    create_event(user, 'module_start', Time.new(2000,01,02), 'bravo')
    create_event(user, 'module_complete', Time.new(2000,01,05), 'bravo')
  end

  let(:charlie_start) do
    create_event(user, 'module_start', Time.new(2000,01,04), 'charlie')
  end
  
  describe '#update_time' do
    context 'when no modules have been taken'
      it 'returns empty hash' do
        completion_time.update_time
        expect(user1.module_time_to_completion).to eq Hash.new
      end
    end

    context 'when alpha has been completed' do
      before do
        alpha_start_and_complete
      end

      it 'returns hash containing time to complete alpha' do
        completion_time.update_time
        expect(user.module_time_to_completion).to eq('alpha' => 172800)
      end

    context 'when bravo has been completed' do
      before do
        alpha_start_and_complete
        bravo_start_and_complete
      end
    
      it 'returns hash containing time to complete alpha and bravo' do
        completion_time.update_time
        expect(user.module_time_to_completion).to eq('alpha' => 172800, 'bravo' => 259200)
      end
    end

    context 'when charlie has been started' do
      before do
        alpha_start_and_complete
        bravo_start_and_complete
        charlie_start
      end
  
      it 'returns hash containing time to complete alpha and bravo, charlie as a zero' do
        completion_time.update_time
        expect(user.module_time_to_completion).to eq('alpha' => 172800, 'bravo' => 259200, 'charlie' => 0)
      end
    end
  end
end
