require 'rails_helper'

RSpec.describe 'When a user visits the module overview page' do
  include_context 'with progress'
  include_context 'with user'

  context 'when the user has not begun the module' do
    before do
      visit '/modules/alpha'
    end

    it 'shows first submodule has not been started yet' do
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('not started')
      end

      within '#section-content-1' do
        expect(page).to have_content('1-1-1').and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end

      expect(page).to have_link('Start', href: '/modules/alpha/content-pages/before-you-start')
    end

    it 'shows the end of module test has not been attempted' do
      within '#section-content-3' do
        expect(page).not_to have_content('in progress')
        expect(page).not_to have_content('completed')
      end
    end

    it 'shows the module recap is not clickable' do
      expect(page).not_to have_link('Reflect on your learning', href: '/modules/alpha/content-pages/1-3-3')
    end
  end

  context 'when the user has viewed the interruption page and module intro' do
    before do
      start_module(alpha)
      visit '/modules/alpha'
    end

    it 'shows first submodule has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end

      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('1-1-1')
          .and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end

      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/intro')
    end
  end

  context 'when the user has viewed the first submodule page' do
    before do
      start_first_submodule(alpha)
      visit '/modules/alpha'
    end

    it 'shows submodule has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end

      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('not started')
          .and have_link('1-1-1', href:  '/modules/alpha/content-pages/1-1-1')
      end

      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/1-1')
    end
  end

  context 'when the user has viewed the first topic page' do
    before do
      start_first_topic(alpha)
      visit '/modules/alpha'
    end

    it 'shows first topic has been completed' do
      within '#section-button-1' do
        expect(page).to have_content('in progress')
      end

      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('complete')
      end

      within '#section-content-1 .govuk-list li:nth-child(2)' do
        expect(page).to have_content('not started')
          .and have_link('1-1-2', href:  '/modules/alpha/content-pages/1-1-2')
      end

      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/1-1-1')
    end
  end

  context 'when the user has finished the first submodule' do
    before do
      view_pages_before_formative_questionnaire(alpha)
      visit '/modules/alpha'
    end

    it 'shows first submodule is complete' do
      within '#section-button-1' do
        expect(page).to have_content('complete')
      end

      within '#section-content-1 .govuk-list' do
        expect(page).to have_content('complete', count: 4)
      end

      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/1-1-4')
    end
  end

  context 'when the user has failed a summative assessment' do
    before do
      start_summative_assessment(alpha)
      visit '/modules/alpha/questionnaires/1-3-2-1'
      3.times do
        check 'Wrong answer 1'
        check 'Wrong answer 2'
        click_on 'Save and continue'
      end
      choose 'Wrong answer 1'
      click_on 'Finish test'
      visit '/modules/alpha'
    end

    specify { expect(page).to have_link('Retake test') }
  end
end
