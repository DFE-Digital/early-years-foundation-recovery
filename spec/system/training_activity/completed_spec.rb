require 'rails_helper'

RSpec.describe 'User modules "Completed"', type: :system do
  include_context 'with user'

  context 'when no modules have been completed' do
    before do
      visit '/my-learning'
    end

    it 'is empty' do
      within '#completed' do
        expect(page).to have_text('Completed modules')
        expect(page).not_to have_text('A Training Module')
      end
    end
  end

  context 'when a module is completed' do
    before do
      visit '/modules/one/content_pages/1-1'    # first page after module intro
      visit '/modules/one/content_pages/1-2-3'  # last page
      visit '/my-learning'
    end

    it 'shows the finished module' do
      within '#completed' do
        expect(page).to have_text('A Training Module')
      end
    end
  end
end
