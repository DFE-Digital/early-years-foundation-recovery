require 'rails_helper'

RSpec.describe 'Certificate' do
  include_context 'with user'
  include_context 'with progress'

  context 'when module is not completed' do
    before do
      visit '/modules/alpha/content-pages/1-3-4'
    end

    it 'shows not completed' do
      expect(page).to have_text 'You have not yet completed the module.'
    end

    it 'omits their name' do
      expect(page).not_to have_text user.first_name
      expect(page).not_to have_text user.last_name
    end
  end

  context 'when module is completed' do
    before do
      complete_module(alpha)
      visit '/modules/alpha/content-pages/1-3-4'
    end

    it 'shows completed' do
      expect(page).to have_text 'Congratulations! You have now completed this module.'
    end

    it 'includes their name' do
      expect(page).to have_text user.first_name
      expect(page).to have_text user.last_name
    end
  end

end
