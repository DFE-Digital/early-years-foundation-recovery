require 'rails_helper'

describe 'LinkHelper', type: :helper do
  let(:mod) { Training::Module.ordered.first }

  let(:user) { create(:user, :registered) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#link_to_next' do
    subject(:link) { helper.link_to_next }

    before do
      without_partial_double_verification do
        allow(view).to receive(:content).and_return(content)
        allow(view).to receive(:mod).and_return(mod)
      end
    end

    context 'when page introduces a section' do
      let(:content) { mod.summary_intro_page }

      it 'targets next page' do
        expect(link).to include 'Start section'
        expect(link).to include 'href="/modules/alpha/content-pages/1-3-1"'
      end
    end

    context 'when page does not introduce a section' do
      let(:content) { mod.pages_by_type('video_page').first }

      it 'targets next page' do
        expect(link).to include 'Next'
        expect(link).to include 'href="/modules/alpha/content-pages/1-2-1-3"'
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
    subject(:link) { helper.link_to_previous }

    before do
      without_partial_double_verification do
        allow(view).to receive(:content).and_return(content)
        allow(view).to receive(:mod).and_return(mod)
      end
    end

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
        create :assessment, :failed, user: user, training_module: mod.name
      end

      it 'links to retake' do
        expect(link).to include 'Retake end of module test'
        expect(link).to include 'href="/modules/alpha/assessment-result/new"'
      end
    end

    context 'with a passed assessment' do
      before do
        create :assessment, :passed, user: user, training_module: mod.name

        mod.summative_questions.map do |question|
          create :response, user: user,
                            training_module: mod.name,
                            question_name: question.name,
                            question_type: 'summative',
                            answers: question.correct_answers
        end
      end

      it 'links to results' do
        expect(link).to include 'View previous test result'
        expect(link).to include 'href="/modules/alpha/assessment-result/1-3-2-11"'
      end
    end
  end

  describe '#link_to_action' do
    subject(:link) { helper.link_to_action }

    before do
      without_partial_double_verification do
        allow(view).to receive(:mod).and_return(mod)
        allow(view).to receive(:module_progress).and_return(module_progress)
      end
    end

    let(:user) { create :user, :registered }

    let(:module_progress) do
      ModuleOverviewDecorator.new ModuleProgress.new(user: user, mod: mod)
    end

    context 'with no activity' do
      it 'targets the interruption page' do
        expect(link).to eq ['Start module', '/modules/alpha/content-pages/what-to-expect']
      end
    end

    context 'with progress' do
      include_context 'with progress'

      it 'targets the most recently visited page' do
        start_first_topic(mod)
        expect(link).to eq ['Resume module', '/modules/alpha/content-pages/1-1-1']
        start_second_submodule(mod)
        expect(link).to eq ['Resume module', '/modules/alpha/content-pages/1-1-1']
      end
    end

    context 'with failed assessment' do
      before do
        create :assessment, :failed, user: user, training_module: mod.name
      end

      it 'targets new assessment attempt' do
        expect(link).to eq ['Retake test', '/modules/alpha/assessment-result/new']
      end
    end
  end
end
