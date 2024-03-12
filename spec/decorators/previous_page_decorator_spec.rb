# Helps to make notes:
#
#   feedback-intro (opinion_intro)
#   end-of-module-feedback-1 (feedback)
#   end-of-module-feedback-3 (feedback)
#   feedback-freetext (feedback)
#   end-of-module-feedback-5 (feedback) <-- SKIPPABLE
#   1-3-3-5 (thankyou)
#
#
require 'rails_helper'

RSpec.describe PreviousPageDecorator do
  subject(:decorator) do
    described_class.new(user: user, mod: mod, content: content, assessment: assessment)
  end

  let(:user) { create :user, :registered }
  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('1-1-2') }
  let(:assessment) { double }

  describe '#style' do
    it do
      expect(decorator.style).to eq 'govuk-button--secondary'
    end

    context 'when page introduces a section' do
      let(:content) { mod.page_by_name('1-2') }

      it do
        expect(decorator.style).to eq 'section-intro-previous-button'
      end
    end
  end

  describe '#text' do
    it do
      expect(decorator.text).to eq 'Previous'
    end
  end

  describe '#name' do
    it 'is previous page name' do
      expect(decorator.name).to eq '1-1-1'
    end

    context 'when feedback was skipped' do
      let(:content) { mod.page_by_name('1-3-3-5') }

      it 'skips back to start of feedback form' do
        expect(decorator.name).to eq 'feedback-intro'
      end
    end

    context 'when previous page is skippable' do
      # This context is insufficiently prepared
      #
      # The assertion here is that a special kind of feedback question is asked
      # in every form but once answered is never asked again.
      #
      # Therefore, as we transition through 'alpha' in this spec, we need a scenario
      # where the question was answered in the main feedack form or another module.
      #
      let(:content) { mod.page_by_name('1-3-3-5') }

      context 'and unanswered' do
        it 'is one step back' do
          expect(decorator.name).to eq 'feedback-checkbox-otherandtext'
        end
      end

      context 'and answered' do
        before do
          create :response,
                 question_name: 'feedback-checkbox-otherandtext',
                 training_module: 'alpha',
                 answers: [1],
                 correct: true,
                 user: create(:user)
        end

        it 'is two steps back' do
          expect(decorator.name).to eq 'feedback-freetext'
        end
      end
    end
  end
end
