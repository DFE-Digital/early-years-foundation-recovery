require 'rails_helper'

RSpec.describe 'Front page' do
  context 'with an authenticated user' do
    include_context 'with user'

    it 'logged in content' do
      visit '/'

      expect(page).to have_text 'Learn more'

      if Rails.application.gov_one_login?
        expect(page).not_to have_text 'Learn more about this training'
        expect(page).not_to have_text 'Start your training now'
      else
        expect(page).not_to have_text 'Learn more and enrol'
        expect(page).not_to have_text 'Sign in to continue learning'
      end
    end
  end

  context 'with an unauthenticated visitor' do
    it 'log in content' do
      visit '/'

      if Rails.application.gov_one_login?
        expect(page).to have_text 'Learn more about this training'
        expect(page).to have_text 'Start your training now'
      else
        expect(page).to have_text 'Learn more and enrol'
        expect(page).to have_text 'Sign in to continue learning'
      end
    end
  end
end
