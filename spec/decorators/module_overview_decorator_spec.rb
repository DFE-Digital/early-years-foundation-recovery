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
      it 'goes to the icons page' do
        expect(user.events.count).to be_zero
        expect(output[:state]).to be :not_started
        expect(output[:page]).to eql 'before-you-start'
      end
    end

    context 'when the module has begun' do
      # NB: user has gone back, so last visited page is not the furthest
      before do
        %w[
          what-to-expect
          before-you-start
          intro
          1-1
          1-1-1
          1-1-2
          1-1-2-1
          1-1-2
        ].map do |page|
          view_module_page_event('bravo', page)
        end
      end

      it 'goes to the furthest page' do
        expect(user.events.count).to be 8
        expect(output[:state]).to be :started
        expect(output[:page]).to eql '1-1-2-1'
      end
    end

    context 'when the assessment was failed' do
      before do
        fail_summative_assessment(bravo)
      end

      it 'retakes the assessment' do
        expect(output[:state]).to be :failed
        expect(output[:page]).to eql '1-2-2-1a'
      end
    end

    context 'when the module has been completed' do
      before do
        view_whole_module(bravo)
      end

      it 'goes to the certificate' do
        expect(user.events.count).to be 15
        expect(output[:state]).to be :completed
        expect(output[:page]).to eql '1-2-3'
      end
    end
  end

  # describe '#topics_by_submodule' do
  # end

  # describe '#status' do
  # end
end
