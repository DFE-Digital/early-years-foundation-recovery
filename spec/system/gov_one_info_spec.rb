require 'rails_helper'

RSpec.describe 'Gov One Info' do
  before do
    allow(Rails.application).to receive(:gov_one_login?).and_return(false)
    visit '/gov-one/info'
  end

  context 'with an unauthenticated visitor' do
    it 'displays the correct content' do
      expect(page).to have_css('h1', text: 'How to access this training course')
      expect(page).to have_css('p', text: 'This service uses GOV.UK One Login which is managed by the Government Digital Service.')
      expect(page).to have_css('p', text: 'You will be asked to sign in to your account, or create a One Login account, in this service')
      expect(page).to have_css('a', text: 'Continue to GOV.UK One Login')
    end
  end

  context 'with an authenticated user' do
    include_context 'with user'

    it 'redirects to the my modules page' do
      expect(page).to have_current_path('/my-modules')
    end
  end
end
