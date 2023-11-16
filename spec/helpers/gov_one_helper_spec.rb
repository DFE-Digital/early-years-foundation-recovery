require 'rails_helper'

describe 'GovOneHelper', type: :helper do
  describe '#login_uri' do
    subject(:login_uri) { helper.login_uri }

    it 'encodes the authorize endpoint params' do
      expect(login_uri).to start_with 'https://oidc.test.account.gov.uk/authorize?response_type=code&scope=email+openid&client_id=some_client_id&'
      expect(login_uri).to end_with 'redirect_uri=http://recovery.app/users/auth/openid_connect/callback'
    end
  end

  describe '#logout_uri' do
    subject(:logout_uri) { helper.logout_uri }

    it 'encodes the logout endpoint params' do
      expect(logout_uri).to start_with 'https://oidc.test.account.gov.uk/logout?id_token_hint&state='
      expect(logout_uri).to end_with '&post_logout_redirect_uri=http://recovery.app/users/sign_out'
    end
  end

  describe '#login_button' do
    subject(:login_button) { helper.login_button }

    it 'returns a button link to the gov one login uri' do
      expect(login_button).to include 'govuk-button'
      expect(login_button).to include 'Continue to GOV.UK One Login'
      expect(login_button).to include 'href="https://oidc.test.account.gov.uk/authorize?response_type=code&amp;scope=email+openid&amp;client_id=some_client_id&'
    end
  end

  describe '#logout_button' do
    subject(:logout_button) { helper.logout_button }

    it 'returns a button link to the gov one logout uri' do
      expect(logout_button).to include 'govuk-button'
      expect(logout_button).to include 'Sign out of Gov One Login'
      expect(logout_button).to include 'href="https://oidc.test.account.gov.uk/logout?id_token_hint&amp;state='
    end
  end
end
