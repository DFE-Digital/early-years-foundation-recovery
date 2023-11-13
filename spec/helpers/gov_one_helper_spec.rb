require 'rails_helper'

describe 'GovOneHelper', type: :helper do
  describe '#login_uri' do
    subject(:login_uri) { helper.login_uri }

    it 'returns a URI object with the correct host and path' do
      expect(login_uri.host).to eq 'oidc.test.account.gov.uk'
      expect(login_uri.path).to eq '/authorize'
    end

    it 'encodes the authorize endpoint params' do
      expect(login_uri.query).to start_with 'response_type=code&scope=email+openid&client_id='
      expect(login_uri.query).to end_with '&redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fauth%2Fopenid_connect%2Fcallback'
    end
  end

  describe '#logout_uri' do
    subject(:logout_uri) { helper.logout_uri }

    it 'returns a URI object with the correct host and path' do
      expect(logout_uri.host).to eq 'oidc.test.account.gov.uk'
      expect(logout_uri.path).to eq '/logout'
    end

    it 'encodes the logout endpoint params' do
      expect(logout_uri.query).to start_with 'id_token_hint&state='
      expect(logout_uri.query).to end_with '&post_logout_redirect_uri=http%3A%2F%2Frecovery.app%2Fusers%2Fsign_out'
    end
  end
end
