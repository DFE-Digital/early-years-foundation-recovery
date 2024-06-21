require 'rails_helper'

RSpec.describe ModuleOverviewDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: bravo) }
  let(:bravo) { Training::Module.by_name('bravo') }

  include_context 'with progress'

  describe '#call_to_action' do
    let(:output) { decorator.call_to_action }
    let(:state) { output[0] }
    let(:page_name) { output[1].name }

    context 'when the module has not begun' do
      it 'goes to the prompt page' do
        expect(user.events.count).to be_zero
        expect(state).to be :not_started
        expect(page_name).to eq 'what-to-expect'
      end
    end

    context 'when the module has begun' do
      before do
        start_second_submodule(bravo)           # navigate to 1-2
        view_module_page_event('bravo', '1-1')  # navigate to 1-1
      end

      it 'goes to the most recently visited page' do
        expect(user.events.count).to be 7
        expect(state).to be :started
        expect(page_name).to eq '1-1'
      end
    end

    context 'when the assessment was failed' do
      before do
        create :assessment, :failed, user: user, training_module: 'bravo'
      end

      it 'retakes the assessment' do
        expect(state).to be :failed
        expect(page_name).to eq '1-3-2'
      end
    end

    context 'when the module has been completed' do
      before do
        complete_module(bravo)
      end

      it 'goes to the certificate' do
        expect(user.events.count).to be 32
        expect(state).to be :completed
        expect(page_name).to eq '1-3-4'
      end
    end
  end
end
