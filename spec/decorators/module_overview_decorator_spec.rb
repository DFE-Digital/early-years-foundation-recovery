require 'rails_helper'

RSpec.describe ModuleOverviewDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: bravo) }
  let(:bravo) { TrainingModule.find_by(name: :bravo) }

  include_context 'with progress'

  describe '#call_to_action' do
    let(:output) do
      decorator.call_to_action do |state, (mod, item)|
        { state: state, module: mod.title, page: item&.name }
      end
    end

    it 'checks the module' do
      expect(output[:module]).to eql 'Second Training Module'
    end

    context 'when the module has not begun' do
      it 'goes to the interruption page' do
        expect(user.events.count).to be_zero
        expect(output[:state]).to be :not_started
        expect(output[:page]).to eql 'before-you-start'
      end
    end

    context 'when the module has begun' do
      it 'goes to the furthest page' do
        %w[
          before-you-start
          intro
          1-1
          1-1-1
          1-1-2
          1-1-2-1a
          1-1-2
        ].map do |page|
          view_module_page_event('bravo', page)
        end

        expect(user.events.count).to be 7
        expect(output[:state]).to be :started
        expect(output[:page]).to eql '1-1-2-1a'
      end
    end

    context 'when the module has been completed' do
      it 'retakes the assessment' do
        bravo.module_items.map { |i| view_module_page_event('bravo', i.name) }

        expect(user.events.count).to be 13 
        expect(output[:state]).to be :completed
        expect(output[:page]).to eql 'certificate'
      end
    end
  end

  # describe '#topics_by_submodule' do

  # end

  # describe '#status' do
  # end
end
