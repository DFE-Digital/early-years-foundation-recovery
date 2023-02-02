require 'rails_helper'

RSpec.describe ModuleOverviewDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: bravo) }
  let(:bravo) { TrainingModule.find_by(name: :bravo) }

  include_context 'with progress'

  describe '#call_to_action' do
    let(:output) do
      decorator.call_to_action do |state, item|
        { state: state, page: item.name }
      end
    end

    context 'when the module has not begun' do
      it 'goes to the prompt page' do
        expect(user.events.count).to be_zero
        expect(output[:state]).to be :not_started
        expect(output[:page]).to eq 'what-to-expect'
      end
    end

    context 'when the module has begun' do
      before do
        start_second_submodule(bravo)
        view_module_page_event('bravo', '1-1') # visit previous page
      end

      it 'goes to the furthest page' do
        expect(user.events.count).to be 8
        expect(output[:state]).to be :started
        expect(output[:page]).to eq '1-2'
      end
    end

    context 'when the assessment was failed' do
      before do
        fail_summative_assessment(bravo)
      end

      it 'retakes the assessment' do
        expect(output[:state]).to be :failed
        expect(output[:page]).to eq '1-3-2'
      end
    end

    context 'when the module has been completed' do
      before do
        complete_module(bravo)
      end

      it 'goes to the certificate' do
        expect(user.events.count).to be 24
        expect(output[:state]).to be :completed
        expect(output[:page]).to eq '1-3-4'
      end
    end
  end

  # describe '#topics_by_submodule' do
  # end

  # describe '#status' do
  # end
end
