require 'rails_helper'

RSpec.describe ModuleProgressBarDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: alpha) }
  let(:alpha) { TrainingModule.find_by(name: :alpha) }

  include_context 'with progress'

  describe 'indexes' do
    let(:indexes) { decorator.progress_bar_info.map { |hash| hash[:index] } }

    specify { expect(indexes).to eq [0, 1, 2, 3] }
  end

  describe 'headings' do
    let(:headings) { decorator.progress_bar_info.map { |hash| hash[:heading] } }

    specify do
      expect(headings).to eq ['Module introduction', 'The first submodule', 'The second submodule', 'Summary and next steps']
    end
  end

  describe 'firsts' do
    let(:firsts) { decorator.progress_bar_info.map { |hash| hash[:first] } }

    specify { expect(firsts).to eq [true, false, false, false] }
  end

  describe 'positions' do
    let(:positions) { decorator.progress_bar_info.map { |hash| hash[:position] } }

    specify { expect(positions).to eq ['Step 1: ', 'Step 2: ', 'Step 3: ', 'Step 4: '] }
  end

  context 'when on module intro section' do
    context 'when on interruption page' do
      before do
        view_pages_before(alpha, 'interruption_page')
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--grey', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [true, false, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [started, not started, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on icons page' do
      before do
        view_pages_before(alpha, 'icons_page')
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--grey', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [true, false, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [started, not started, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on module intro page' do
      before do
        start_module(alpha)
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--grey', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [true, false, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [completed, not started, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end
  end

  context 'when on first submodule section' do
    context 'when on sub_module_intro page' do
      before do
        start_first_submodule(alpha)
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--green', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [false, true, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [completed, started, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on first content page' do
      before do
        start_first_topic(alpha)
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--green', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [false, true, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [completed, started, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on final content page' do
      before do
        view_pages_before_formative_questionnaire(alpha)
      end

      describe 'classes' do
        let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

        specify { expect(classes).to eq [nil, 'line line--green', 'line line--grey', 'line line--grey'] }
      end

      describe 'bolds' do
        let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

        specify { expect(bolds).to eq [false, true, false, false] }
      end

      describe 'content_helper_values' do
        let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

        it 'has nodes [completed, completed, not started, not started]' do
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end
  end
end
