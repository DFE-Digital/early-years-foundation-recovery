require 'rails_helper'

RSpec.describe 'Gov One' do
  context 'with an unauthenticated visitor' do
    before do
      visit '/users/sign-in'
    end

    it 'displays the correct content' do
      expect(page).to have_text 'How to access this training course'
      expect(page).to have_text 'This service uses GOV.UK One Login which is managed by the Government Digital Service.'
      expect(page).to have_text 'You will be asked to sign in to your account, or create a One Login account, in this service'
      expect(page).to have_text 'Continue to GOV.UK One Login'
      expect(page).to have_text 'If you have an existing early years child development training account but you do not yet have a GOV.UK One Login, you must use the same email address for both accounts. This will ensure that any progress you have made through the training is retained.'
    end
  end

  context 'with an authenticated user' do
    include_context 'with user'

    before do
      visit '/users/sign-in'
    end

    it 'redirects to the home page' do
      expect(page).to have_current_path '/'
      expect(page).to have_text 'You are already signed in.'
    end
  end
end
