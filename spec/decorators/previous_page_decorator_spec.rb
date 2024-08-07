# Helps to make notes:
#
#   feedback-intro (opinion_intro)
#   end-of-module-feedback-1 (feedback)
#   end-of-module-feedback-3 (feedback)
#   feedback-textarea-only (feedback)
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
      let(:content) { mod.page_by_name('1-3-3-5') }

      context 'and answered' do
        before do
          create :response,
                 question_name: 'feedback-skippable',
                 training_module: mod.name,
                 answers: [1],
                 correct: true,
                 user: user,
                 question_type: 'feedback'
        end

        specify { expect(decorator.name).to eq 'feedback-checkbox-other-or' }
      end
    end
  end
end
