require 'rails_helper'

RSpec.describe 'Gov One' do
  before do
    skip unless Rails.application.gov_one_login?
  end

  context 'with an unauthenticated visitor' do
    before do
      visit '/users/sign-in'
    end

    it 'displays the correct content' do
      expect(page).to have_text 'How to access this training course'
      expect(page).to have_text 'This service uses GOV.UK One Login which is managed by the Government Digital Service.'
      expect(page).to have_text 'You will be asked to sign in to your account, or create a One Login account, in this service'
      expect(page).to have_text 'Continue to GOV.UK One Login'
    end
  end

  context 'with an authenticated user' do
    include_context 'with user'

    before do
      visit '/users/sign-in'
    end

    it 'redirects to the my modules page' do
      expect(page).to have_current_path '/my-modules'
    end
  end
end
