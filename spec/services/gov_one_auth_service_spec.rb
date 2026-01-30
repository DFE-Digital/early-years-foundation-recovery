require 'rails_helper'

shared_examples 'a one login request' do
  it 'returns a hash of the expected payload' do
    expect(result).to eq(payload)
    expect(auth_service).to have_received(:response).with(an_instance_of(request_type), an_instance_of(Net::HTTP))
  end
end

RSpec.describe GovOneAuthService do
  let(:code) { 'mock_code' }
  let(:mock_response) { instance_double('response') }
  let(:auth_service) { described_class.new(code: code) }
  let(:payload) { { 'info' => 'auth_info' } }

  before do
    allow(auth_service).to receive(:response).and_return(mock_response)
    allow(mock_response).to receive(:body).and_return(payload.to_json)
  end

  describe '#tokens' do
    let(:result) { auth_service.tokens }
    let(:request_type) { Net::HTTP::Post }

    context 'when successful' do
      it_behaves_like 'a one login request'
    end

    context 'when unsuccessful' do
      let(:payload) { {} }

      it_behaves_like 'a one login request'
    end
  end

  describe '#user_info' do
    let(:access_token) { 'mock_access_token' }
    let(:result) { auth_service.user_info(access_token) }
    let(:request_type) { Net::HTTP::Get }

    context 'when successful' do
      it_behaves_like 'a one login request'
    end

    context 'when unsuccessful' do
      let(:payload) { {} }

      it_behaves_like 'a one login request'
    end
  end

  describe '#token_body' do
    let(:token_body) { auth_service.send(:token_body) }

    it 'returns a hash of correct token body' do
      expect(token_body[:grant_type]).to eq('authorization_code')
      expect(token_body[:code]).to eq(code)
      expect(token_body[:redirect_uri]).to end_with('/users/auth/openid_connect/callback')
      expect(token_body[:client_assertion_type]).to eq('urn:ietf:params:oauth:client-assertion-type:jwt-bearer')
    end
  end

  describe '#jwt_payload' do
    let(:jwt_payload) { auth_service.send(:jwt_payload) }

    it 'returns a hash of correct jwt payload' do
      expect(jwt_payload[:aud]).to eq 'https://oidc.test.account.gov.uk/token'
      expect(jwt_payload[:iss]).to eq 'some_client_id'
      expect(jwt_payload[:sub]).to eq 'some_client_id'
      expect(jwt_payload[:exp]).to be_between(Time.zone.now.to_i + 4 * 60, Time.zone.now.to_i + 6 * 60)
      expect(jwt_payload[:jti]).to be_a String
      expect(jwt_payload[:iat]).to be_a Integer
    end
  end

  describe 'Internal callbacks' do
    subject(:callbacks) { described_class::CALLBACKS }

    specify 'login' do
      expect(callbacks[:login]).to eq 'http://recovery.app/users/auth/openid_connect/callback'
    end

    specify 'logout' do
      expect(callbacks[:logout]).to eq 'http://recovery.app/users/sign_out'
    end
  end

  describe 'OIDC endpoints' do
    subject(:endpoints) { described_class::ENDPOINTS }

    specify 'login endpoint for starting gov one user session and redirecting back to service' do
      expect(endpoints[:login]).to eq 'https://oidc.test.account.gov.uk/authorize'
    end

    specify 'logout endpoint for ending gov one user session and redirecting back to service' do
      expect(endpoints[:logout]).to eq 'https://oidc.test.account.gov.uk/logout'
    end

    specify 'token endpoint for retrieving user access token and id token' do
      expect(endpoints[:token]).to eq 'https://oidc.test.account.gov.uk/token'
    end

    specify 'userinfo endpoint for retrieving user email' do
      expect(endpoints[:userinfo]).to eq 'https://oidc.test.account.gov.uk/userinfo'
    end

    specify 'jwks endpoint for retrieving public key for verifying user id token' do
      expect(endpoints[:jwks]).to eq 'https://oidc.test.account.gov.uk/.well-known/jwks.json'
    end
  end

  describe 'JWKS/key rotation logic' do
    let(:jwt_token) { 'mock.jwt.token' }
    let(:kid) { 'test-kid' }
    let(:other_kid) { 'other-kid' }
    let(:jwks_keys) { { 'keys' => [{ 'kid' => kid, 'kty' => 'RSA', 'n' => 'test', 'e' => 'AQAB' }] } }
    let(:jwks_keys_other) { { 'keys' => [{ 'kid' => other_kid, 'kty' => 'RSA', 'n' => 'test', 'e' => 'AQAB' }] } }
    let(:jwks_response) do
      instance_double(Net::HTTPResponse, code: '200', body: jwks_keys.to_json).tap do |resp|
        allow(resp).to receive(:[]).with('Cache-Control').and_return(nil)
      end
    end
    let(:jwks_response_other) do
      instance_double(Net::HTTPResponse, code: '200', body: jwks_keys_other.to_json).tap do |resp|
        allow(resp).to receive(:[]).with('Cache-Control').and_return(nil)
      end
    end
    let(:cache_control_response) do
      instance_double(Net::HTTPResponse, code: '200', body: jwks_keys.to_json).tap do |resp|
        allow(resp).to receive(:[]).with('Cache-Control').and_return('max-age=1234')
      end
    end
    let(:discovery_response) do
      instance_double(Net::HTTPResponse, code: '200', body: { 'jwks_uri' => 'https://custom-jwks' }.to_json)
    end
    let(:mock_http) { http_with_request(jwks_response) }
    let(:mock_http_other) { http_with_request(jwks_response_other) }
    let(:mock_http_cache_control) { http_with_request(cache_control_response) }
    let(:mock_http_discovery) { http_with_request(discovery_response) }

    def http_with_request(response)
      instance_double('MockHTTP', request: response).tap do |http|
        allow(http).to receive(:use_ssl=)
      end
    end

    before do
      allow(JWT).to receive(:decode).and_return([{}, { 'kid' => kid }])
      allow(JWT::JWK).to receive(:new).and_return(instance_double('JWK', public_key: 'pubkey'))
      allow(Rails.cache).to receive(:fetch).and_call_original
      allow(Rails.cache).to receive(:delete)
      allow(Rails.cache).to receive(:write)
      allow(Rails.cache).to receive(:read)
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
    end

    it 'refreshes JWKS cache and retries verification on kid miss' do
      allow(JWT).to receive(:decode).and_return([{}, { 'kid' => other_kid }])
      # Both initial and refreshed JWKS do not contain the kid (empty keys array)
      jwks_keys_empty = { 'keys' => [] }
      jwks_response_empty = instance_double(Net::HTTPResponse, code: '200', body: jwks_keys_empty.to_json)
      allow(jwks_response_empty).to receive(:[]).with('Cache-Control').and_return(nil)
      mock_http_empty = http_with_request(jwks_response_empty)
      http_client_double = class_double(Net::HTTP, new: mock_http_empty)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      expect(Rails.cache).to receive(:delete).with('jwks')
      expect(Rails.logger).to receive(:warn).with(/JWKS kid/)
      expect(Rails.logger).to receive(:error).with(/kid #{other_kid} not found after JWKS refresh/)
      expect { auth_service.decode_id_token(jwt_token) }.to raise_error(JWT::DecodeError)
    end

    it 'sets JWKS cache expiry from Cache-Control header' do
      http_client_double = class_double(Net::HTTP, new: mock_http_cache_control)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      expect(Rails.cache).to receive(:write).with('jwks', anything, expires_in: 1234)
      auth_service.send(:fetch_jwks_with_cache, force_refresh: true)
    end

    it 'falls back to cached JWKS on fetch failure' do
      failing_http = instance_double('FailingHTTP')
      allow(failing_http).to receive(:request).and_raise(StandardError, 'network error')
      allow(failing_http).to receive(:use_ssl=)
      http_client_double = class_double(Net::HTTP, new: failing_http)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      allow(Rails.cache).to receive(:read).with('jwks').and_return([jwks_keys, false])
      expect(Rails.logger).to receive(:warn).with(/stale JWKS/)
      expect { auth_service.send(:fetch_jwks_with_cache, force_refresh: true) }.not_to raise_error
    end

    it 'fetches JWKS URI from OpenID discovery endpoint' do
      http_client_double = class_double(Net::HTTP, new: mock_http_discovery)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      expect(auth_service.send(:jwks_uri_from_discovery)).to eq('https://custom-jwks')
    end

    it 'logs JWKS refresh events and failures' do
      http_client_double = class_double(Net::HTTP, new: mock_http)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      expect(Rails.logger).to receive(:info).with(/Fetched JWKS/)
      auth_service.send(:fetch_jwks_with_cache, force_refresh: true)
      failing_http = instance_double('FailingHTTP')
      allow(failing_http).to receive(:request).and_raise(StandardError, 'network error')
      allow(failing_http).to receive(:use_ssl=)
      http_client_double = class_double(Net::HTTP, new: failing_http)
      auth_service = described_class.new(code: code, http_client: http_client_double)
      expect(Rails.logger).to receive(:error).with(/GovOneAuthService.jwks/)
      begin
        auth_service.send(:fetch_jwks_with_cache, force_refresh: true)
      rescue StandardError
        # expected
      end
    end
  end
end
