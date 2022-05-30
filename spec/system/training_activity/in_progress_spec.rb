require 'rails_helper'

RSpec.describe 'User modules "In progress"', type: :system do
  include_context 'with user'

  context 'when no modules have been started' do
    before do
      visit '/my-learning'
    end

    it 'is empty' do
      within '#started' do
        expect(page).not_to have_text('A Training Module')
        expect(page).to have_text('In progress')
          .and have_text('You have not started any modules.')
      end
    end
  end

  context 'when a module has been started' do
    before do
      visit '/modules/one/content_pages/1-1'  # first page after module intro
      visit '/my-learning'
    end

    it 'shows the module' do
      within '#started' do
        expect(page).not_to have_text('You have not started any modules.')
        expect(page).to have_text('In progress').and have_text('A Training Module')
      end
    end
  end

  context 'when a module is completed' do
    before do
      visit '/modules/one/content_pages/1-1'    # first page after module intro
      visit '/modules/one/content_pages/1-2-3'  # last page
      visit '/my-learning'
    end

    it 'does not show the module' do
      within '#started' do
        expect(page).not_to have_text('A Training Module')
        expect(page).to have_text('In progress')
          .and have_text('You have not started any modules.')
      end
    end
  end
end
