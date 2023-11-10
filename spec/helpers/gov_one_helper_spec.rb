require 'rails_helper'

RSpec.describe GovOneHelper do
  let(:class_instance) { Class.new { include GovOneHelper }.new }

  before do
    allow(Rails.application.config).to receive(:gov_one_base_uri).and_return('https://example.com')
    allow(Rails.application.config).to receive(:gov_one_redirect_uri).and_return('https://example.com/redirect')
    allow(Rails.application.config).to receive(:gov_one_logout_redirect_uri).and_return('https://example.com/logout-redirect')
    allow(Rails.application.config).to receive(:gov_one_client_id).and_return('client_id')
  end

  describe '#gov_one_uri' do
    it 'constructs the URI with correct parameters' do
      endpoint = 'authorize'
      params = { response_type: 'code', scope: 'email openid', client_id: 'client_id' }

      uri = class_instance.send(:gov_one_uri, endpoint, params)

      expect(uri.to_s).to eq('https://example.com/authorize?response_type=code&scope=email+openid&client_id=client_id')
    end
  end

  describe '#login_uri' do
    it 'constructs the URI with correct parameters' do
      result = class_instance.login_uri
      uri = URI.parse(result)

      expect(uri.to_s).to include('https://example.com/authorize')
      expect(uri.query).to include('response_type=code', 'scope=email+openid', 'client_id=client_id', 'redirect_uri=https://example.com/redirect')
    end
  end

  describe '#logout_uri' do
    before do
      allow(class_instance).to receive(:current_id_token).and_return('mock_id_token')
    end

    it 'constructs the URI with correct parameters' do
      result = class_instance.logout_uri
      uri = URI.parse(result)

      expect(uri.to_s).to include('https://example.com/logout')
      expect(uri.query).to include('id_token_hint=mock_id_token', 'state=', 'post_logout_redirect_uri=https://example.com/logout-redirect')
    end
  end
end
