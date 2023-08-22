require 'rails_helper'

describe 'LinkHelper', type: :helper do
  let(:mod) { Training::Module.ordered.first }

  describe '#link_to_next' do
    subject(:link) { helper.link_to_next(content) }

    context 'when page is midway' do
      let(:content) { mod.confidence_intro_page }

      it 'targets next page' do
        expect(link).to include 'href="/modules/alpha/content-pages/1-3-3-1"'
      end
    end

    context 'when page is last' do
      let(:content) { mod.certificate_page }

      it 'targets itself' do
        expect(link).to include 'href="/modules/alpha/content-pages/1-3-4"'
      end

      it 'offers feedback to content authors' do
        expect(link).to include 'Next page has not been created'
      end
    end
  end

  describe '#link_to_previous' do
    subject(:link) { helper.link_to_previous(content) }

    context 'when page is midway' do
      let(:content) { mod.page_by_name('1-1') }

      it 'targets previous page' do
        expect(link).to include 'href="/modules/alpha/content-pages/what-to-expect"'
      end
    end

    context 'when page is first' do
      let(:content) { mod.interruption_page }

      it 'targets module overview' do
        expect(link).to include 'href="/modules/alpha"'
      end
    end
  end

  describe '#link_to_retake_or_results' do
    subject(:link) { helper.link_to_retake_or_results(mod) }

    let(:user) { create :user, :registered }

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when no assessment attempt is made' do
      specify { expect(link).to be_nil }
    end

    context 'with a failed assessment' do
      before do
        create :user_assessment, :failed, user_id: user.id, score: 0, module: mod.name
      end

      it 'links to retake' do
        expect(link).to include 'Retake end of module test'
        expect(link).to include 'href="/modules/alpha/assessment-result/new"'
      end
    end

    context 'with a passed assessment' do
      before do
        create :user_assessment, user_id: user.id, module: mod.name

        mod.summative_questions.map do |question|
          if ENV['DISABLE_USER_ANSWER'].present?
            create :response, user: user,
                              training_module: mod.name,
                              question_name: question.name,
                              answers: question.correct_answers
          else
            create :user_answer, user: user,
                                 module: mod.name,
                                 name: question.name,
                                 answer: question.correct_answers,
                                 questionnaire_id: 0
          end
        end
      end

      it 'links to results' do
        expect(link).to include 'View previous test result'
        expect(link).to include 'href="/modules/alpha/assessment-result/1-3-2-5"'
      end
    end
  end

  describe '#link_to_action' do
    subject(:link) { helper.link_to_action(state, content) }

    let(:content) { mod.interruption_page } # any page works
    let(:state) { :not_started }

    it 'targets current page' do
      expect(link).to include 'href="/modules/alpha/content-pages/what-to-expect"'
    end

    context 'with failed assessment' do
      let(:state) { :failed }

      it 'targets new assessment attempt' do
        expect(link).to include 'href="/modules/alpha/assessment-result/new"'
      end
    end
  end
end
