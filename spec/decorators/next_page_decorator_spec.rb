require 'rails_helper'

RSpec.describe NextPageDecorator do
  subject(:decorator) do
    described_class.new(user: user, mod: mod, content: content, assessment: assessment)
  end

  let(:user) { create :user, :registered }
  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('1-1-1') }
  let(:assessment) { double }

  it '#name' do
    expect(decorator.name).to eq '1-1-2'
  end

  it '#text' do
    expect(decorator.text).to eq 'Next'
  end

  it '#disable_question_submission?' do
    expect(decorator.disable_question_submission?).to be false
  end

  context 'when adding to the learning log' do
    let(:content) { mod.page_by_name('1-1-3-1') }

    it '#text' do
      expect(decorator.text).to eq 'Save and continue'
    end
  end

  context 'when starting a section' do
    let(:content) { mod.page_by_name('1-2') }

    it '#text' do
      expect(decorator.text).to eq 'Start section'
    end
  end

  context 'when starting an assessment' do
    let(:content) { mod.page_by_name('1-3-2') }

    it '#text' do
      expect(decorator.text).to eq 'Start test'
    end
  end

  context 'when answering an assessment question' do
    let(:content) { mod.page_by_name('1-3-2-1') }

    it '#text' do
      expect(decorator.text).to eq 'Save and continue'
    end
  end

  context 'when finishing an assessment' do
    let(:content) { mod.page_by_name('1-3-2-10') }

    it '#text' do
      expect(decorator.text).to eq 'Finish test'
    end
  end

  context 'when reviewing a completed assessment' do
    let(:content) { mod.page_by_name('1-3-2-1') }
    let(:assessment) { instance_double(AssessmentProgress, graded?: true, score: 100) }

    before do
      if Rails.application.migrated_answers?
        create :response,
               user: user,
               question_name: '1-3-2-1',
               question_type: 'summative',
               training_module: 'alpha',
               answers: [1],
               assessment: create(:assessment, user: user)
      else
        create :user_answer,
               user: user,
               name: '1-3-2-1',
               module: 'alpha',
               assessments_type: 'summative_assessment',
               question: 'N/A for CMS only questions',
               questionnaire_id: 0,
               answer: [1]
      end
    end

    it '#text' do
      expect(decorator.text).to eq 'Next'
    end

    it '#disable_question_submission?' do
      expect(decorator.disable_question_submission?).to be true
    end
  end

  context 'when finishing a module' do
    let(:content) { mod.page_by_name('1-3-3-5') }

    it '#text' do
      expect(decorator.text).to eq 'Finish'
    end
  end
end
