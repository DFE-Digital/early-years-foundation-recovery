require 'rails_helper'

RSpec.describe GovOneHelper do
  let(:class_instance) { Class.new { include GovOneHelper }.new }

  before do
    allow(Rails.application.config).to receive(:gov_one_logout_redirect_uri).and_return('mock_logout_redirect_uri')
  end

  describe '#gov_one_uri' do
    it 'constructs the URI with correct parameters' do
      endpoint = 'authorize'
      params = { response_type: 'code', scope: 'email openid', client_id: 'client_id' }

      uri = class_instance.send(:gov_one_uri, endpoint, params)

      expect(uri.to_s).to eq('https://oidc.integration.account.gov.uk/authorize?response_type=code&scope=email+openid&client_id=client_id')
    end
  end

  describe '#login_uri' do
    it 'constructs the URI with correct parameters' do
      uri = class_instance.login_uri

      expect(uri.to_s).to include('https://oidc.integration.account.gov.uk/authorize')
      expect(uri.query).to include('response_type=code', 'scope=email+openid', 'client_id=client_id', 'redirect_uri=mock_redirect_uri')
    end
  end

  describe '#logout_uri' do
    before do
      allow(class_instance).to receive(:current_id_token).and_return('mock_id_token')
    end

    it 'constructs the URI with correct parameters' do
      uri = class_instance.logout_uri

      expect(uri.to_s).to include('https://oidc.integration.account.gov.uk/logout')
      expect(uri.query).to include('id_token_hint=mock_id_token', 'state=', 'post_logout_redirect_uri=mock_logout_redirect_uri')
    end
  end
end
