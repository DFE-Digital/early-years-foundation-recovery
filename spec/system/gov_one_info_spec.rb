require 'rails_helper'

RSpec.describe 'Gov One Info' do
  context 'when the user is not logged in' do
    before do
      visit '/gov-one/info'
    end

    it 'displays the correct content' do
      expect(page).to have_css('h1', text: 'How to access this training course')
      expect(page).to have_css('p', text: 'This service uses GOV.UK One Login which is managed by the Government Digital Service.')
      expect(page).to have_css('p', text: 'You will be asked to sign in to your account, or create a One Login account, in this service')
      expect(page).to have_css('a', text: 'Continue to GOV.UK One Login')
    end

    it 'has the correct login link' do
      link = find_link('Continue to GOV.UK One Login')
      expect(link[:href]).to start_with('https://oidc.test.account.gov.uk/authorize?response_type=code&scope=email+openid&client_id=some_client_id')
      expect(link[:href]).to end_with('&redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fauth%2Fopenid_connect%2Fcallback')
    end
  end

  context 'when the user is logged in' do
    include_context 'with user'

    it 'they are redirected to the my modules page' do
      visit '/gov-one/info'
      expect(page).to have_current_path('/my-modules')
    end
  end
end
