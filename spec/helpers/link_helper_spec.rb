require 'rails_helper'
EventStub = Struct.new(:name, :properties, :time)
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

      specify do
        expect(link).to include 'Next page has not been created'
      end
    end

    context 'when next section is feedback questions' do
      let(:content) { mod.page_by_name('feedback-intro') }

      specify do
        expect(link).to include 'Give feedback'
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
        expect(link).to include 'href="/modules/alpha/content-pages/1-3-2"'
      end
    end

    context 'with a passed assessment' do
      before do
        create :assessment, :passed, user: user, training_module: mod.name

        mod.summative_questions.each do |question|
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

    context 'with no activity' do
      let(:module_progress) do
        ModuleOverviewDecorator.new(ModuleProgress.new(user: user, mod: mod))
      end

      it 'targets the interruption page' do
        expect(link).to eq ['Start module', '/modules/alpha/content-pages/what-to-expect']
      end
    end

    context 'with progress' do
      let(:now) { Time.zone.now }

      let!(:progress_record) do
        create(
          :user_module_progress,
          user: user,
          module_name: 'alpha',
          started_at: now - 6.minutes,
          last_page: '1-1-3-1',
          visited_pages: {
            'what-to-expect' => (now - 6.minutes).iso8601,
            '1-1' => (now - 5.minutes).iso8601,
            '1-1-1' => (now - 4.minutes).iso8601,
            '1-1-2' => (now - 3.minutes).iso8601,
            '1-1-3' => (now - 2.minutes).iso8601,
            '1-1-3-1' => (now - 1.minute).iso8601,
          },
        )
      end

      let(:module_progress) do
        ModuleOverviewDecorator.new(ModuleProgress.new(user: user, mod: mod, user_module_progress: progress_record))
      end

      it 'targets the most recently visited page' do
        expect(link).to eq ['Resume module', '/modules/alpha/content-pages/1-1-3-1']
      end
    end

    context 'with failed assessment' do
      let(:module_progress) do
        ModuleOverviewDecorator.new(ModuleProgress.new(user: user, mod: mod))
      end

      before do
        UserModuleProgress.create!(user: user, module_name: 'alpha', started_at: Time.zone.now)
        create :assessment, :failed, user: user, training_module: mod.name
      end

      it 'targets new assessment attempt' do
        expect(link).to eq ['Retake test', '/modules/alpha/content-pages/1-3-2']
      end
    end
  end

  describe '#link_to_skip_feedback' do
    subject(:link) { helper.link_to_skip_feedback }

    before do
      without_partial_double_verification do
        allow(view).to receive(:content).and_return(content)
        allow(view).to receive(:mod).and_return(mod)
      end
    end

    context 'when page is feedback intro' do
      let(:content) { mod.page_by_name('feedback-intro') }

      it 'targets thank you page' do
        expect(link).to include 'Skip feedback'
      end
    end
  end
end
