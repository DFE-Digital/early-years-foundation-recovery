require 'rails_helper'

RSpec.describe CalculateModuleState do
  subject(:service) { described_class.new(user: user) }

  let(:day_one) { Time.zone.local(2000, 0o1, 0o1) } # start alpha
  let(:day_two) { Time.zone.local(2000, 0o1, 0o2) } # start bravo
  let(:day_three) { Time.zone.local(2000, 0o1, 0o3) } # complete alpha
  let(:day_five) { Time.zone.local(2000, 0o1, 0o5) } # complete bravo

  include_context 'with events'

  describe '#call' do
    context 'when there is no module activity' do
      it 'records no module state' do
        expect(service.call).to eq({})
      end
    end

    context 'when there are "in progress" modules and no named events' do
      before do
        user.update!(module_time_to_completion: { alpha: 0 })
      end

      # @see BackfillModuleState
      it 'fails to calculate duration' do
        expect(service.call).to eq('alpha' => nil)
      end
    end

    context 'when there are "completed" modules and no named events' do
      before do
        user.update!(module_time_to_completion: { alpha: 999 })
      end

      it 'does not update duration' do
        expect(service.call).to eq('alpha' => 999)
      end
    end

    context 'when a module is started' do
      before do
        create_event(user, 'module_start', day_one, 'alpha')
      end

      it 'records a value of zero' do
        expect(service.call).to eq('alpha' => 0)
      end
    end

    context 'when a module is completed' do
      before do
        create_event(user, 'module_start', day_one, 'alpha')
        create_event(user, 'module_complete', day_three, 'alpha')
      end

      it 'records a value greater than zero' do
        expect(service.call).to eq('alpha' => 172_800)
      end

      context 'and the next module is started' do
        before do
          create_event(user, 'module_start', day_two, 'bravo')
        end

        it 'appends the module to the state object' do
          expect(service.call).to eq('alpha' => 172_800, 'bravo' => 0)
        end

        context 'and then completed' do
          before do
            create_event(user, 'module_complete', day_five, 'bravo')
          end

          it 'calculates the delta between named events in seconds' do
            expect(service.call).to eq('alpha' => 172_800, 'bravo' => 259_200)
          end
        end
      end
    end
  end
end
