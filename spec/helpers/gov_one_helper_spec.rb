require 'rails_helper'

describe 'GovOneHelper', type: :helper do
  describe '#login_uri' do
    subject(:login_uri) { helper.login_uri }

    it 'encodes the authorize endpoint params' do
      expect(login_uri).to start_with 'https://oidc.test.account.gov.uk/authorize?response_type=code&scope=email+openid&client_id='
      expect(login_uri).to end_with 'redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fauth%2Fopenid_connect%2Fcallback'
    end
  end

  describe '#logout_uri' do
    subject(:logout_uri) { helper.logout_uri }

    it 'encodes the logout endpoint params' do
      expect(logout_uri).to start_with 'https://oidc.test.account.gov.uk/logout?id_token_hint&state='
      expect(logout_uri).to end_with '&post_logout_redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fsign_out'
    end
  end

  describe '#login_button' do
    subject(:login_button) { helper.login_button }

    it 'returns a link to the login uri' do
      expect(login_button).to include 'govuk-button'
      expect(login_button).to include 'Sign in with Gov One Login'
    end
  end

  describe '#logout_button' do
    subject(:logout_button) { helper.logout_button }

    it 'returns a link to the login uri' do
      expect(logout_button).to include 'govuk-button'
      expect(logout_button).to include 'Sign out of Gov One Login'
    end
  end
end
