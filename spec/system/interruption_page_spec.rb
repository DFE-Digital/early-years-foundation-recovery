require 'rails_helper'

RSpec.describe 'Interruption page', type: :system do
  context 'with an authenticated user' do
    include_context 'with user'

    before do
      visit '/modules/alpha/content-pages/what-to-expect'
    end

    it 'can click on the next button' do
      click_on 'Next'
      expect(page).to have_current_path '/modules/alpha'
    end

    it 'can click on the previous button' do
      click_on 'Previous'
      expect(page).to have_current_path '/my-modules'
    end
  end
end
