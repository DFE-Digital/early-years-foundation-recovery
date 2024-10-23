require 'rails_helper'

RSpec.describe 'Errors page', type: :feature do
  context 'when the page is not found (404 error)' do
    before do
      visit '/404'
    end

    it 'displays a "Page not found" message' do
      expect(page).to have_content 'Page not found'
      expect(page.status_code).to eq(404)
    end
  end

  context 'when there is an internal server error (500 error)' do
    before do
      visit '/500'
    end

    it 'displays a "Sorry, there is a problem with the service" message' do
      expect(page).to have_content 'Sorry, there is a problem with the service'
      expect(page.status_code).to eq(500)
    end
  end

  context 'when the service is unavailable (503 error)' do
    before do
      visit '/503'
    end

    it 'displays a "Service Unavailable" message' do
      expect(page).to have_content 'Service Unavailable'
      expect(page.status_code).to eq(503)
    end
  end
end
