require 'rails_helper'

RSpec.describe ModuleProgressBarDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: alpha) }
  let(:alpha) { TrainingModule.find_by(name: :alpha) }

  include_context 'with progress'

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

  describe 'line styling' do
    let(:classes) { decorator.progress_bar_info.map { |hash| hash[:class] } }

    context 'when on module intro section' do
      it 'all lines are grey' do
        view_pages_before(alpha, 'interruption_page')
        expect(classes).to eq [nil, 'line line--grey', 'line line--grey', 'line line--grey']
      end
    end

    context 'when on first submodule' do
      context 'when on sub_module_intro' do
        it 'all lines are grey' do
          start_first_submodule(alpha)
          expect(classes).to eq [nil, 'line line--grey', 'line line--grey', 'line line--grey']
        end
      end

      context 'when on content pages' do
        it 'first line is green, next two are grey' do
          start_first_topic(alpha)
          expect(classes).to eq [nil, 'line line--green', 'line line--grey', 'line line--grey']
        end
      end
    end

    context 'when on second submodule' do
      context 'when on sub_module_intro' do
        it 'first line is green, next two are grey' do
          start_second_submodule(alpha)
          expect(classes).to eq [nil, 'line line--green', 'line line--grey', 'line line--grey']
        end
      end

      context 'when on content pages' do
        it 'first two lines are green, next one is grey' do
          view_pages_before(alpha, 'text_page', 5)
          expect(classes).to eq [nil, 'line line--green', 'line line--green', 'line line--grey']
        end
      end
    end

    context 'when on summary section' do
      context 'when on summary_intro' do
        it 'first two lines are green, next one is grey' do
          view_summary_intro(alpha)
          expect(classes).to eq [nil, 'line line--green', 'line line--green', 'line line--grey']
        end
      end

      context 'when on summative assessment and confidence check' do
        it 'all lines are green' do
          start_summative_assessment(alpha)
          expect(classes).to eq [nil, 'line line--green', 'line line--green', 'line line--green']
        end
      end
    end
  end

  describe 'bold headings' do
    let(:bolds) { decorator.progress_bar_info.map { |hash| hash[:bold] } }

    context 'when on module intro section' do
      it 'first heading is bold' do
        view_pages_before(alpha, 'interruption_page')
        expect(bolds).to eq [true, false, false, false]
      end
    end

    context 'when on first submodule' do
      it 'second heading is bold' do
        start_first_submodule(alpha)
        expect(bolds).to eq [false, true, false, false]
      end
    end

    context 'when on second submodule' do
      it 'third heading is bold' do
        start_second_submodule(alpha)
        expect(bolds).to eq [false, false, true, false]
      end
    end

    context 'when on summary section' do
      it 'last heading is bold' do
        view_summary_intro(alpha)
        expect(bolds).to eq [false, false, false, true]
      end
    end
  end

  describe 'status of progress nodes' do
    let(:content_helper_values) { decorator.progress_bar_info.map { |hash| hash[:content_helper_values] } }

    context 'when on module introduction section' do
      context 'when on interruption page and icons page' do
        it 'first node is started and last three are not started' do
          view_pages_before(alpha, 'interruption_page')
          expect(content_helper_values).to eq [
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end

      context 'when on module intro page' do
        it 'first node is completed and last three are not started' do
          start_module(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on submodule section' do
      context 'when on submodule_intro page' do
        it 'previous node is completed next nodes are not started' do
          start_first_submodule(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end

      context 'when on first content page' do
        it 'previous node is completed, this node is started and next nodes are not started' do
          start_first_topic(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :solid, :green, 'started'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end

      context 'when on last content page' do
        it 'previous and current nodes are completed, next nodes are not started' do
          view_pages_before_formative_questionnaire(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end
    end

    context 'when on summary section' do
      context 'when on summary_intro page' do
        it 'previous nodes are completed, this node is not started' do
          view_summary_intro(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :regular, :grey, 'not started'],
          ]
        end
      end

      context 'when on summative assessment or confidence check' do
        it 'previous nodes are completed, this node is started' do
          start_summative_assessment(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle', :solid, :green, 'started'],
          ]
        end
      end

      context 'when on certificate page' do
        it 'all nodes are completed' do
          view_certificate_page(alpha)
          expect(content_helper_values).to eq [
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
            ['circle-check', :solid, :green, 'completed'],
          ]
        end
      end
    end
  end
end
