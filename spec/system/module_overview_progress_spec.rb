require 'rails_helper'

RSpec.describe 'When a user visits the module overview page' do
  include_context 'with progress'
  include_context 'with user'
  
  
  context 'when the user has not begun the module' do
    before do
      visit '/modules/alpha'
    end

    it 'first submodule has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end

      within '#section-content-1' do
        expect(page).to have_content('1-1-1')
          .and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end

      click_on('Start')
      expect(page).to have_current_path('/modules/alpha/content-pages/before-you-start')
    end
  end
  
  context 'when the user has viewed the interruption page and module intro' do
    before do
      start_module(alpha)
      visit '/modules/alpha'
    end

    it 'first submodule has not been started yet' do
      within '#section-button-1' do
        expect(page).to have_content('not started')
      end
    
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('1-1-1')
          .and have_content('not started')
        expect(page).not_to have_link('1-1-1')
      end

      click_on('Resume training')
      expect(page).to have_current_path('/modules/alpha/content-pages/intro')
    end
  end

  context 'when the user has viewed the first submodule page' do
    before do
      start_submodule(alpha)
      visit '/modules/alpha'
    end

    it 'submodule has been started' do
      within '#section-button-1' do
        expect(page).to have_content('in progress')
      end
    
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('not started')
        click_on('1-1-1')
        expect(page).to have_current_path('/modules/alpha/content-pages/1-1-1')
      end

      # flaky test - seems to depend on the order
      click_on('Resume training')
      expect(page).to have_current_path('/modules/alpha/content-pages/1-1')
    end
  end

  context 'when the user has viewed the first topic' do
    before do
      start_topic(alpha)
      visit '/modules/alpha'
    end

    it 'first topic has been started' do
      within '#section-button-1' do
        expect(page).to have_content('in progress')
      end
    
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('in progress')
        click_on('1-1-2')
        expect(page).to have_current_path('/modules/alpha/content-pages/1-1-2')
      end

      # flaky test - seems to depend on the order
      click_on('Resume training')
      expect(page).to have_current_path('/modules/alpha/content-pages/1-1-1')
    end
  end

  context 'when the user has finished the first submodule' do
    before do
      start_second_submodule(alpha)
      visit '/modules/alpha'
    end

    it 'first submodule is complete' do
      within '#section-button-1' do
        expect(page).to have_content('complete')
      end
    
      within '#section-content-1 .govuk-list li:first-child' do
        expect(page).to have_content('complete')
      end

      # flaky test - seems to depend on the order
      click_on('Resume training')
      expect(page).to have_current_path('/modules/alpha/content-pages/1-2')
    end
  end
end
