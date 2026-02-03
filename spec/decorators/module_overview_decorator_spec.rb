require 'rails_helper'

RSpec.describe ModuleOverviewDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:bravo) { Training::Module.by_name('bravo') }
  let(:progress) { ModuleProgress.new(user: user, mod: bravo) }

  include_context 'with progress'

  describe '#sections' do
    let(:output) { decorator.sections }

    it 'have sequential positions' do
      expect(output.map { |s| s[:position] }).to eq [1, 2, 3, 4, 4]
    end

    it 'hides feedback section' do
      expect(output.map { |s| s[:hide] }).to eq [false, false, false, true, false]
    end

    it 'counts pages' do
      expect(output.map { |s| s[:page_count] }).to eq [
        '(4 pages)',
        '(5 pages)',
        '(20 pages)',
        '(9 pages)',
        nil,
      ]
    end
  end

  describe '#call_to_action' do
    let(:output) { decorator.call_to_action }
    let(:state) { output[0] }
    let(:page_name) { output[1].name }

    context 'when the module has not begun' do
      it 'goes to the prompt page' do
        expect(state).to eq :not_started
        expect(page_name).to eq 'what-to-expect'
      end
    end

    context 'when the module has begun' do
      before do
        start_second_submodule(bravo)           # navigate to 1-2
        view_module_page_event('bravo', '1-1')  # navigate to 1-1
      end

      it 'goes to the most recently visited page' do
        expect(state).to eq :started
        expect(page_name).to eq '1-1'
      end
    end

    context 'when the assessment was failed' do
      before do
        UserModuleProgress.record_page_view(user: user, module_name: 'bravo', page_name: 'what-to-expect')
        create :assessment, :failed, user: user, training_module: 'bravo'
      end

      it 'retakes the assessment' do
        expect(state).to eq :failed
        expect(page_name).to eq '1-3-2'
      end
    end

    context 'when the module has been completed' do
      before do
        complete_module(bravo)
      end

      it 'goes to the certificate' do
        expect(state).to eq :completed
        expect(page_name).to eq '1-3-4'
      end
    end
  end
end
