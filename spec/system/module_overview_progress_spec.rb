require 'rails_helper'

RSpec.describe 'Module overview page progress' do
  include_context 'with progress'
  include_context 'with user'

  context 'when the module has not been started' do
    before do
      visit '/modules/alpha'
    end

    it 'all the indicators are "not started"' do
      within '#section-button-1' do
        expect(page).to have_content 'not started'
      end

      within '#section-content-1 .govuk-list' do
        expect(page).to have_content 'not started', count: 4
      end

      within '#section-button-2' do
        expect(page).to have_content 'not started'
      end

      within '#section-content-1' do
        expect(page).to have_content('1-1-1').and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end

      within '#section-button-3' do
        expect(page).to have_content 'not started'
      end

      within '#section-content-3 .govuk-list' do
        expect(page).to have_content 'not started', count: 3
        expect(page).not_to have_link 'Recap'
        expect(page).not_to have_link 'End of module test'
        expect(page).not_to have_link 'Reflect on your learning'
      end
    end

    it 'resumes from the interruption page' do
      expect(page).to have_link 'Start', href: '/modules/alpha/content-pages/before-you-start'
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

  context 'when the module intro is reached' do
    before do
      start_module(alpha)
      visit '/modules/alpha'
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/intro')
    end
  end

  context 'when the first submodule intro is reached' do
    before do
      start_first_submodule(alpha)
      visit '/modules/alpha'
    end

    it 'the submodule indicator is "not started"' do
      within '#section-button-1' do
        expect(page).to have_content 'not started'
      end
    end

    it 'the first topic indicator is "not started"' do
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content 'not started'
        expect(page).not_to have_link('1-1-1', href: '/modules/alpha/content-pages/1-1-1')
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link('Resume training', href: '/modules/alpha/content-pages/1-1')
    end
  end

  context 'when the first topic is complete' do
    before do
      start_first_topic(alpha)
      visit '/modules/alpha'
    end

    it 'the submodule indicator is "in progress"' do
      within '#section-button-1' do
        expect(page).to have_content 'in progress'
      end
    end

    it 'the first topic indicator is "complete"' do
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content 'complete'
        expect(page).to have_link '1-1-1', href: '/modules/alpha/content-pages/1-1-1'
      end
    end

    it 'the second topic indicator is "not started"' do
      within '#section-content-1 .govuk-list li:nth-child(2)' do
        expect(page).to have_content 'not started'
        expect(page).not_to have_link '1-1-2', href: '/modules/alpha/content-pages/1-1-2'
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link 'Resume training', href: '/modules/alpha/content-pages/1-1-1'
    end
  end

  context 'when the last page of the first submodule is reached' do
    before do
      view_pages_before_formative_questionnaire(alpha)
      visit '/modules/alpha'
    end

    it 'all the indicators in the submodule are "complete"' do
      within '#section-button-1' do
        expect(page).to have_content 'complete'
      end

      within '#section-content-1 .govuk-list' do
        expect(page).to have_content 'complete', count: 4
      end
    end

    it 'resumes from the last visited page' do
      expect(page).to have_link 'Resume training', href: '/modules/alpha/content-pages/1-1-4'
    end
  end

  context 'when the summative assessment is failed' do
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

    specify { expect(page).to have_link 'Retake test' }
  end

  context 'when the whole module is complete' do
    before do
      view_whole_module(alpha)
      visit '/modules/alpha'
    end

    specify { expect(page).not_to have_link 'Retake test' }
  end

  context 'when the whole module is complete' do
    before do
      view_whole_module(alpha)
      visit '/modules/alpha'
    end

    specify { expect(page).not_to have_link('Retake test') }
  end
end
