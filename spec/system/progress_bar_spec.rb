require 'rails_helper'

RSpec.describe 'Progress bar' do
  include_context 'with user'
  include_context 'with progress'

  context 'when on first submodule' do
    describe 'submodule intro page' do
      before do
        start_module(alpha)
        visit 'modules/alpha/content-pages/1-1'
      end

      it 'shows a circle with a green border' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'final topic page' do
      before do
        view_pages_upto_formative_question(alpha)
        visit 'modules/alpha/questionnaires/1-1-4'
      end

      it 'shows a green circle with a tick' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
      end
    end
  end

  context 'when on second submodule' do
    describe 'submodule intro page' do
      before do
        start_second_submodule(alpha)
        visit 'modules/alpha/content-pages/1-2'
      end

      it 'shows a green circle with a tick on first submodule and green circle on second submodule' do
        expect(page).to have_selector 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
        expect(page).to have_selector 'li.progress-bar--item:nth-child(2) .fa-circle.green'
      end

      it 'shows a bold section heading on second submodule' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'final topic page' do
      before do
        view_pages_upto_formative_question(alpha, 3)
        visit 'modules/alpha/questionnaires/1-2-1-3'
      end

      it 'shows two green circles with a tick' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .fa-circle-check.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .progress--heading.govuk-\!-font-weight-bold'
      end
    end
  end

  context 'when on module summary' do
    describe 'summary intro' do
      before do
        view_summary_intro(alpha)
        visit 'modules/alpha/content-pages/1-3'
      end

      it 'shows a circle with a green border, and previous with tick' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(3) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(3) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'when on confidence check' do
      before do
        start_confidence_check(alpha)
        visit 'modules/alpha/content-pages/1-3'
      end

      it 'shows a circle with a green border, and previous with tick' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(3) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(3) .progress--heading.govuk-\!-font-weight-bold'
      end
    end
  end

  context 'with just a completion event' do
    describe 'the whole progress bar' do
      before do
        module_complete_event(alpha)
        visit 'modules/alpha/content-pages/1-1'
      end

      it 'shows all nodes are ticked' do
        expect(page).to have_css 'li.progress-bar--item:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(2) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar--item:nth-child(3) .fa-circle-check.green'
      end
    end
  end
end
