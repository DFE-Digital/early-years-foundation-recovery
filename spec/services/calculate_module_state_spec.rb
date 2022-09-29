require 'rails_helper'

RSpec.describe CalculateModuleState do
  subject(:completion_time) { described_class.new(user: user) }

  include_context 'with events'

  let(:alpha_start_and_complete) do
    create_event(user, 'module_start', Time.zone.local(2000, 0o1, 0o1), 'alpha')
    create_event(user, 'module_complete', Time.zone.local(2000, 0o1, 0o3), 'alpha')
  end

  let(:bravo_start_and_complete) do
    create_event(user, 'module_start', Time.zone.local(2000, 0o1, 0o2), 'bravo')
    create_event(user, 'module_complete', Time.zone.local(2000, 0o1, 0o5), 'bravo')
  end

  let(:charlie_start) do
    create_event(user, 'module_start', Time.zone.local(2000, 0o1, 0o4), 'charlie')
  end

  describe '#update_time' do
    context 'when no modules have been taken'
    it 'returns empty hash' do
      completion_time.call
      expect(user1.module_time_to_completion).to eq({})
    end
  end

  context 'when alpha has been completed' do
    before do
      alpha_start_and_complete
    end

    it 'returns hash containing time to complete alpha' do
      completion_time.call
      expect(user.module_time_to_completion).to eq('alpha' => 172_800)
    end

    context 'when bravo has been completed' do
      before do
        alpha_start_and_complete
        bravo_start_and_complete
      end

      it 'returns hash containing time to complete alpha and bravo' do
        ttc = completion_time.call
        expect(ttc).to eq('alpha' => 172_800, 'bravo' => 259_200)
      end
    end

    context 'when charlie has been started' do
      before do
        alpha_start_and_complete
        bravo_start_and_complete
        charlie_start
      end

      it 'returns hash containing time to complete alpha and bravo, charlie as a zero' do
        completion_time.call
        expect(user.module_time_to_completion).to eq('alpha' => 172_800, 'bravo' => 259_200, 'charlie' => 0)
      end
    end
  end
end
