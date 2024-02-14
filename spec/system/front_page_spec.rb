require 'rails_helper'

RSpec.describe 'Front page' do
  context 'with an authenticated user' do
    include_context 'with user'

    it 'logged in content' do
      visit '/'

      expect(page).to have_text 'Learn more'

      expect(page).not_to have_text 'Learn more about this training'
      expect(page).not_to have_text 'Start your training now'

      # banner
      expect(page).not_to have_text 'Access to this website is changing'
      expect(page).not_to have_link href: 'https://www.gov.uk/using-your-gov-uk-one-login'
    end
  end

  context 'with an unauthenticated visitor' do
    it 'log in content' do
      visit '/'

      expect(page).to have_text 'Learn more about this training'
      expect(page).to have_text 'Start your training now'

      # banner
      expect(page).not_to have_text 'Access to this website is changing'
      expect(page).not_to have_link href: 'https://www.gov.uk/using-your-gov-uk-one-login'
    end
  end
end
