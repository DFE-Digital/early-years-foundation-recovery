require 'rails_helper'

describe 'GovOneHelper', type: :helper do
  describe '#login_uri' do
    subject(:login_uri) { helper.login_uri }

    it 'encodes the authorize endpoint params' do
      expect(login_uri.host).to eq 'oidc.test.account.gov.uk'
      expect(login_uri.path).to eq '/authorize'
      expect(login_uri.query).to include 'redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fauth%2Fopenid_connect%2Fcallback'
      expect(login_uri.query).to include 'client_id=some_client_id'
      expect(login_uri.query).to include 'response_type=code'
      expect(login_uri.query).to include 'scope=email+openid'
      expect(login_uri.query).to include 'nonce='
    end
  end

  describe '#logout_uri' do
    subject(:logout_uri) { helper.logout_uri }

    it 'encodes the logout endpoint params' do
      expect(logout_uri.host).to eq 'oidc.test.account.gov.uk'
      expect(logout_uri.path).to eq '/logout'
      expect(logout_uri.query).to include 'post_logout_redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fsign_out'
      expect(logout_uri.query).to include 'id_token_hint'
      expect(logout_uri.query).to include 'state='
    end
  end

  describe '#login_button' do
    subject(:login_button) { helper.login_button }

    it 'returns a button link to the gov one login uri' do
      expect(login_button).to include 'govuk-button'
      expect(login_button).to include 'Continue to GOV.UK One Login'
      expect(login_button).to include 'href="https://oidc.test.account.gov.uk/authorize?redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fauth%2Fopenid_connect%2Fcallback&amp;client_id=some_client_id&amp;response_type=code&amp;scope=email+openid&amp;nonce='
    end
  end
end
