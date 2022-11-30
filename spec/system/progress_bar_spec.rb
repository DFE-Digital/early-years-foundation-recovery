require 'rails_helper'

RSpec.describe 'Progress bar' do
  include_context 'with user'
  include_context 'with progress'

  context 'when on intro section' do
    describe 'first page' do
      it 'shows a circle with a green border' do
        visit 'modules/alpha/content-pages/what-to-expect'
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle.green'
      end
    end

    describe 'second page' do
      it 'shows a circle with a green border' do
        visit 'modules/alpha/content-pages/what-to-expect'
        visit 'modules/alpha/content-pages/before-you-start'
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle.green'
      end
    end

    describe 'final page' do
      it 'shows a green circle with a tick' do
        start_module(alpha)
        visit 'modules/alpha/content-pages/intro'
        expect(page).to have_selector 'li.progress-bar:nth-child(1) .fa-circle-check.green'
      end
    end
  end

  context 'when on first submodule' do
    describe 'intro page' do
      it 'shows first circle ticked, second circle with a grey border' do
        start_first_submodule(alpha)
        visit 'modules/alpha/content-pages/1-1'
        expect(page).to have_css 'li.progress-bar:nth-child(1) .fa-circle-check.green'
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle.grey'
      end
    end

    describe 'first topic page' do
      it 'shows a circle with a green border' do
        start_first_topic(alpha)
        visit 'modules/alpha/content-pages/1-1-1'
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle.green'
      end
    end

    describe 'final topic page' do
      it 'shows a green circle with a tick' do
        view_pages_before_formative_questionnaire(alpha)
        visit 'modules/alpha/questionnaires/1-1-4'
        expect(page).to have_css 'li.progress-bar:nth-child(2) .fa-circle-check.green'
      end
    end
  end
end
