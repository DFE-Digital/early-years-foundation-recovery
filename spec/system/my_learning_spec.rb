require 'rails_helper'

RSpec.describe 'Learning activity', type: :system do
  include_context 'with user'

  before do
    visit '/my-modules'
  end

  context 'when the user has not begun any modules' do
    describe 'In progress' do
      it 'is empty' do
        within '#started' do
          expect(page).to have_text 'Modules in progress'
          expect(page).to have_text 'You have not started any modules.'

          expect(page).not_to have_text 'First Training Module'
          expect(page).not_to have_text 'Third Training Module'
          expect(page).not_to have_text 'Second Training Module'
          expect(page).not_to have_text 'Brain development in early years'
        end
      end
    end

    describe 'Available modules' do
      it 'shows only the first mandatory module' do
        within '#available' do
          expect(page).to have_text 'Available modules'
          expect(page).to have_text 'First Training Module'

          expect(page).not_to have_text 'Second Training Module'
          expect(page).not_to have_text 'Third Training Module'
          expect(page).not_to have_text 'Fourth Training Module'
        end
      end

      it 'visits interruption page when clicked' do
        within '#available' do
          click_link 'Module 1: First Training Module'
          expect(page).to have_current_path '/modules/alpha/what-to-expect'
        end
      end
    end

    describe 'Future modules' do
      it 'shows other modules including drafts' do
        within '#upcoming' do
          expect(page).to have_text 'Future modules in this course'
          expect(page).not_to have_text 'First Training Module'

          within '#bravo' do
            expect(page).to have_text 'Second Training Module'
            expect(page).to have_link 'View more information about this module', href: '/about-training#module-2-second-training-module'
          end

          within '#charlie' do
            expect(page).to have_text 'Third Training Module'
            expect(page).to have_link 'View more information about this module', href: '/about-training#module-3-third-training-module'
          end

          # unpublished draft module
          within '#delta' do
            expect(page).to have_text 'Fourth Training Module'
            expect(page).not_to have_link 'View more information about this module', href: '/about-training#module-4-fourth-training-module'
          end
        end
      end
    end

    describe 'Completed modules' do
      it 'is hidden' do
        expect(page).not_to have_selector '#completed'
      end
    end
  end

  context 'when a user has started the first mandatory module' do
    before do
      visit '/modules/alpha/content-pages/intro'
      visit '/my-modules'
    end

    it 'shows the started module' do
      within '#started' do
        expect(page).to have_text 'Modules in progress'
        expect(page).to have_text 'First Training Module'
        expect(page).not_to have_text 'You have not started any modules.'
      end
    end

    it 'visits my modules page when clicked' do
      within '#started' do
        click_link 'Module 1: First Training Module'
        expect(page).to have_current_path '/modules/alpha'
      end
    end
  end
end
