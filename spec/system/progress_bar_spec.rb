require 'rails_helper'

RSpec.describe 'Progress bar' do
  include_context 'with user'
  include_context 'with progress'

  context 'when on intro section' do
    describe 'first page' do
      before do
        visit 'modules/alpha/content-pages/what-to-expect'
      end

      it 'shows a circle with a green border' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'second page' do
      before do
        visit 'modules/alpha/content-pages/what-to-expect'
        visit 'modules/alpha/content-pages/before-you-start'
      end

      it 'shows a circle with a green border' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'final page' do
      before do
        start_module(alpha)
        visit 'modules/alpha/content-pages/intro'
      end

      it 'shows a green circle with a tick' do
        expect(page).to have_selector 'li.progress-bar:nth-child(1) .fa-circle-check.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
      end
    end
  end

  context 'when on first submodule' do
    describe 'intro page' do
      before do
        start_first_submodule(alpha)
        visit 'modules/alpha/content-pages/1-1'
      end

      it 'shows first circle ticked, second circle with a grey border' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle.grey'
      end

      it 'shows regular first section heading, bold section section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(1) .progress--heading.govuk-\!-font-weight-bold'
        expect(page).not_to have_css 'li.progress-bar:nth-child(2) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'first topic page' do
      before do
        start_first_topic(alpha)
        visit 'modules/alpha/content-pages/1-1-1'
      end

      it 'shows a circle with a green border' do
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(2) .progress--heading.govuk-\!-font-weight-bold'
      end
    end

    describe 'final topic page' do
      before do
        view_pages_before_formative_questionnaire(alpha)
        visit 'modules/alpha/questionnaires/1-1-4'
      end

      it 'shows a green circle with a tick' do
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle-check.green'
      end

      it 'shows a bold section heading' do
        expect(page).to have_css 'li.progress-bar:nth-child(2) .progress--heading.govuk-\!-font-weight-bold'
      end
    end
  end
end
