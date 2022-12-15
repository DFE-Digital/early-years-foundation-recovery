require 'rails_helper'

RSpec.describe ModuleProgressBarDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:alpha) { TrainingModule.find_by(name: :alpha) }
  let(:progress) { ModuleProgress.new(user: user, mod: alpha) }

  let(:key) { :heading }
  let(:attribute) { decorator.nodes.map { |node| node[key] } }

  include_context 'with progress'

  describe '#nodes' do
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

    describe ':icon' do
      let(:key) { :icon }

      let(:not_started) { { icon_type: 'circle', style: :regular, colour: :grey, status: 'not started' } }
      let(:started) { { icon_type: 'circle', style: :solid, colour: :green, status: 'started' } }
      let(:completed) { { icon_type: 'circle-check', style: :solid, colour: :green, status: 'completed' } }

      context 'when on module introduction section' do
        context 'and on first two pages' do
          it 'first node has green circle and next nodes have a grey circle' do
            view_pages_before(alpha, 'interruption_page')
            expect(attribute).to eq [started, not_started, not_started, not_started]
          end
        end

        context 'when on last page' do
          it 'first node has green tick and next nodes have grey circle' do
            start_module(alpha)
            expect(attribute).to eq [completed, not_started, not_started, not_started]
          end
        end
      end

      context 'when in submodule section' do
        context 'and on first page' do
          it 'previous nodes have green tick, this and next nodes have grey circle' do
            start_first_submodule(alpha)
            expect(attribute).to eq [completed, not_started, not_started, not_started]
          end
        end

        context 'and on neither first nor last page' do
          it 'previous nodes have green tick, this node has green circle and next nodes have grey circle' do
            start_first_topic(alpha)
            expect(attribute).to eq [completed, started, not_started, not_started]
          end
        end

        context 'and on last page' do
          it 'previous and current nodes have green tick, next nodes have grey circle' do
            view_pages_before_formative_questionnaire(alpha)
            expect(attribute).to eq [completed, completed, not_started, not_started]
          end
        end
      end

      context 'when in summary section' do
        context 'and on first page' do
          it 'previous nodes have green tick, last node has grey circle' do
            view_summary_intro(alpha)
            expect(attribute).to eq [completed, completed, completed, not_started]
          end
        end

        context 'and on neither first nor last page' do
          it 'previous nodes have green tick, last node has green circle' do
            start_summative_assessment(alpha)
            expect(attribute).to eq [completed, completed, completed, started]
          end
        end

        context 'and on last page' do
          it 'all nodes have green tick' do
            view_certificate_page(alpha)
            expect(attribute).to eq [completed, completed, completed, completed]
          end
        end
      end
    end
  end

  describe '#furthest_section' do
    context 'when on module introduction section' do
      specify do
        view_pages_before(alpha, 'interruption_page')
        expect(decorator.furthest_section).to eq 'You have reached section 1 of 4: Module introduction'
      end
    end

    context 'when on first subodule section' do
      specify do
        start_first_submodule(alpha)
        expect(decorator.furthest_section).to eq 'You have reached section 2 of 4: The first submodule'
      end
    end

    context 'when on second submodule section' do
      specify do
        start_second_submodule(alpha)
        expect(decorator.furthest_section).to eq 'You have reached section 3 of 4: The second submodule'
      end
    end

    context 'when on final submodule' do
      specify do
        view_summary_intro(alpha)
        expect(decorator.furthest_section).to eq 'You have reached section 4 of 4: Summary and next steps'
      end
    end
  end
end
