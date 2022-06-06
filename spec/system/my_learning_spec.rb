require 'rails_helper'

RSpec.describe 'Learning activity', type: :system do
  include_context 'with user'

  before do
    visit '/my-learning'
  end

  context 'when the user has not begun any modules' do
    describe 'In progress' do
      it 'is empty' do
        within '#started' do
          expect(page).to have_text 'In progress'
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
    end

    describe 'Upcoming modules' do
      it 'shows the other mandatory modules' do
        within '#upcoming' do
          expect(page).to have_text 'Upcoming modules'
          expect(page).to have_text 'Second Training Module'
          expect(page).to have_link 'View more information about this module', href: '/modules/bravo'

          expect(page).to have_text 'Third Training Module'
          expect(page).to have_link 'View more information about this module', href: '/modules/charlie'

          # unpublished draft module
          expect(page).to have_text 'Fourth Training Module'
          expect(page).not_to have_link 'View more information about this module', href: '/modules/delta'

          expect(page).not_to have_text 'First Training Module'
        end
      end
    end

    describe 'Completed modules' do
      it 'is hidden' do
        expect(page).not_to have_selector '#completed'
      end
    end
  end

  # context 'when none have been started' do
  #   it 'is empty' do
  #     within '#started' do
  #       expect(page).not_to have_text 'A Training Module'
  #       expect(page).to have_text('In progress')
  #         .and have_text('You have not started any modules.')
  #     end
  #   end
  # end

  # context 'when a module has been started' do
  #   before do
  #     visit '/modules/one/content_pages/1-1'  # first page after module intro
  #     visit '/my-learning'
  #   end

  #   it 'shows the module' do
  #     within '#started' do
  #       expect(page).not_to have_text('You have not started any modules.')
  #       expect(page).to have_text('In progress').and have_text('A Training Module')
  #     end
  #   end
  # end

  # context 'when a module is completed' do
  #   before do
  #     visit '/modules/one/content_pages/1-1'    # first page after module intro
  #     visit '/modules/one/content_pages/1-2-3'  # last page
  #     visit '/my-learning'
  #   end

  #   it 'does not show the module' do
  #     within '#started' do
  #       expect(page).not_to have_text('A Training Module')
  #       expect(page).to have_text('In progress')
  #         .and have_text('You have not started any modules.')
  #     end
  #   end
  # end
end
