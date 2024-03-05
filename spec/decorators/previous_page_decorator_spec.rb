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

  describe '#text' do
    it do
      expect(decorator.text).to eq 'Previous'
    end
  end

  describe '#name' do
    it 'is previous page name' do
      expect(decorator.name).to eq '1-1-1'
    end

    context 'when previous page is skippable' do
      let(:content) { mod.page_by_name('1-3-3-5') }

      context 'and unanswered' do
        it 'is one step back' do
          expect(decorator.name).to eq 'end-of-module-feedback-5'
        end
      end

      context 'and answered' do
        before do
          create :response,
            question_name: 'end-of-module-feedback-5',
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
