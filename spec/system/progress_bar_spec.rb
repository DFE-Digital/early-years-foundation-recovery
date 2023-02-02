require 'rails_helper'

RSpec.describe 'Progress bar' do
  include_context 'with user'
  include_context 'with progress'

  context 'when on first submodule' do
    describe 'submodule intro page' do
      before do
        start_first_submodule(alpha)
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
end
