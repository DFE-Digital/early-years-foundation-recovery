require 'rails_helper'

RSpec.describe 'Errors page' do
  context 'when page is not found' do
    before do
      visit '/404'
    end

    specify do
      expect(page).to have_content 'Page not found'
    end
  end

  context 'when page is not found using the incorrect format' do
    before do
      visit '/randompage.yml'
    end

    specify do
      expect(page).to have_content 'Page not found'
    end
  end

  context 'when there is an internal server error' do
    before do
      visit '/500'
    end

    specify do
      expect(page).to have_content 'Sorry, there is a problem with the service'
    end
  end

  context 'when there is a service unavailable error' do
    before do
      visit '/503'
    end

    specify do
      expect(page).to have_content 'Service Unavailable'
    end
  end
end
