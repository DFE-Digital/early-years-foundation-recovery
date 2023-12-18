require 'rails_helper'

RSpec.describe 'Front page' do
  context 'with an authenticated user' do
    include_context 'with user'

    it 'logged in content' do
      visit '/'
      expect(page).to have_text 'Learn more'
      expect(page).not_to have_text 'Learn more and enrol'
      expect(page).not_to have_text 'Sign in to continue learning'
    end
  end

  context 'with an unauthenticated visitor' do
    it 'log in content' do
      visit '/'
      expect(page).to have_text('Learn more and enrol')
        .and have_text('Sign in to continue learning')
    end
  end
end
