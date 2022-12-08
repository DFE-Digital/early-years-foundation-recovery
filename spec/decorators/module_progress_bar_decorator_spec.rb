require 'rails_helper'

RSpec.describe ModuleProgressBarDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:alpha) { TrainingModule.find_by(name: :alpha) }
  let(:progress) { ModuleProgress.new(user: user, mod: alpha) }

  let(:key) { :heading }
  let(:attribute) { decorator.nodes.map { |node| node[key] } }

  include_context 'with progress'

  describe '#nodes' do
    describe ':position' do
      let(:key) { :position }

      it 'counts the number of steps for screenreaders' do
        expect(attribute).to eq ['Step 1', 'Step 2', 'Step 3', 'Step 4']
      end
    end

    describe ':heading' do
      let(:key) { :heading }

      it 'displays the submodule heading' do
        expect(attribute).to eq [
          'Module introduction',
          'The first submodule',
          'The second submodule',
          'Summary and next steps',
        ]
      end
    end

    describe ':heading_style' do
      let(:key) { :heading_style }
      let(:style) { 'govuk-!-font-weight-bold' }

      context 'when the first node introduction is reached' do
        it 'emboldens the first node heading' do
          view_pages_before(alpha, 'interruption_page')
          expect(attribute).to eq [style, nil, nil, nil]
        end
      end

      context 'when a submodule node introduction is reached' do
        it 'emboldens submodule 1 once viewed' do
          start_first_submodule(alpha)
          expect(attribute).to eq [nil, style, nil, nil]
        end

        it 'emboldens submodule 2 once viewed' do
          start_second_submodule(alpha)
          expect(attribute).to eq [nil, nil, style, nil]
        end
      end

      context 'when the final node introduction is reached' do
        it 'emboldens the final node heading' do
          view_summary_intro(alpha)
          expect(attribute).to eq [nil, nil, nil, style]
        end
      end
    end

    describe ':line_style' do
      let(:key) { :line_style }
      let(:green) { 'line line--green' }
      let(:grey) { 'line line--grey' }

      context 'when learning has not started' do
        it 'all lines are grey' do
          view_pages_before(alpha, 'interruption_page')
          expect(attribute).to eq [nil, grey, grey, grey]
        end
      end

      context 'when in the first submodule' do
        context 'and on the intro' do
          it 'all lines are grey' do
            start_first_submodule(alpha)
            expect(attribute).to eq [nil, grey, grey, grey]
          end
        end

        context 'and content has been viewed' do
          it 'first line becomes green' do
            start_first_topic(alpha)
            expect(attribute).to eq [nil, green, grey, grey]
          end
        end
      end

      context 'when in the second submodule' do
        context 'and on the intro' do
          it 'first line is green, second line is still grey' do
            start_second_submodule(alpha)
            expect(attribute).to eq [nil, green, grey, grey]
          end
        end

        context 'and content has been viewed' do
          it 'second line becomes green' do
            view_pages_before(alpha, 'text_page', 5)
            expect(attribute).to eq [nil, green, green, grey]
          end
        end
      end

      context 'when in the final submodule' do
        context 'and on the summary intro' do
          it 'last line is still grey' do
            view_summary_intro(alpha)
            expect(attribute).to eq [nil, green, green, grey]
          end
        end

        context 'and the assessment has started' do
          it 'all lines are green' do
            start_summative_assessment(alpha)
            expect(attribute).to eq [nil, green, green, green]
          end
        end
      end
    end

    # OPTIMIZE: improve doc format
    describe ':icon' do
      let(:key) { :icon }

      let(:not_started) { { icon_type: 'circle', style: :regular, colour: :grey, status: 'not started' } }
      let(:started) { { icon_type: 'circle', style: :solid, colour: :green, status: 'started' } }
      let(:completed) { { icon_type: 'circle-check', style: :solid, colour: :green, status: 'completed' } }

      context 'when on module introduction section' do
        context 'when on interruption page and icons page' do
          it 'first node is started and last three are not started' do
            view_pages_before(alpha, 'interruption_page')
            expect(attribute).to eq [started, not_started, not_started, not_started]
          end
        end

        context 'when on module intro page' do
          it 'first node is completed and last three are not started' do
            start_module(alpha)
            expect(attribute).to eq [completed, not_started, not_started, not_started]
          end
        end
      end

      context 'when on submodule section' do
        context 'when on submodule_intro page' do
          it 'previous node is completed next nodes are not started' do
            start_first_submodule(alpha)
            expect(attribute).to eq [completed, not_started, not_started, not_started]
          end
        end

        context 'when on first content page' do
          it 'previous node is completed, this node is started and next nodes are not started' do
            start_first_topic(alpha)
            expect(attribute).to eq [completed, started, not_started, not_started]
          end
        end

        context 'when on last content page' do
          it 'previous and current nodes are completed, next nodes are not started' do
            view_pages_before_formative_questionnaire(alpha)
            expect(attribute).to eq [completed, completed, not_started, not_started]
          end
        end
      end

      context 'when on summary section' do
        context 'when on summary_intro page' do
          it 'previous nodes are completed, this node is not started' do
            view_summary_intro(alpha)
            expect(attribute).to eq [completed, completed, completed, not_started]
          end
        end

        context 'when on summative assessment or confidence check' do
          it 'previous nodes are completed, this node is started' do
            start_summative_assessment(alpha)
            expect(attribute).to eq [completed, completed, completed, started]
          end
        end

        context 'when on certificate page' do
          it 'all nodes are completed' do
            view_certificate_page(alpha)
            expect(attribute).to eq [completed, completed, completed, completed]
          end
        end
      end
    end
  end
end
