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

  let(:mock_contentful) { MockContentfulService.new }
  let(:user) { create :user, :registered }
  let(:mod) { mock_contentful.find('alpha') }
  let(:content) { OpenStruct.new(name: '1-1-2', page_type: 'text_page', title: 'Page 1-1-2') }
  let(:assessment) { double }

  before do
    allow(Training::Module).to receive(:by_name).and_return(mock_contentful.find('alpha'))
    allow(Training::Module).to receive(:ordered).and_return([mock_contentful.find('alpha'), mock_contentful.find('bravo')])
  end

  subject(:decorator) do
    described_class.new(user: user, mod: mod, content: content, assessment: assessment)
  end

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
