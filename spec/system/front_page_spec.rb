require 'rails_helper'

RSpec.describe 'Front page' do
  context 'with an authenticated user' do
    include_context 'with user'

    it 'logged in content' do
      visit '/'
      expect(page).to have_text 'Learn more'
      expect(page).not_to have_text 'Learn more about this training'
      expect(page).not_to have_text 'Start your training now'
    end
  end

  context 'with an unauthenticated visitor' do
    it 'log in content' do
      visit '/'
      expect(page).to have_text('Learn more about this training')
        .and have_text('Start your training now')
    end
  end
end
