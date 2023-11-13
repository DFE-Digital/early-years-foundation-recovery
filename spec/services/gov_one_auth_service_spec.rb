require 'rails_helper'

RSpec.describe GovOneAuthService do
  let(:code) { 'mock_code' }
  let(:mock_response) { instance_double('response') }
  let(:auth_service) { described_class.new(code: code) }
  let(:payload) { { 'info' => 'auth_info' } }

  before do
    allow(auth_service).to receive(:response).and_return(mock_response)
  end

  describe '#tokens' do
    let(:result) { auth_service.tokens }

    context 'when the request is successful' do
      it 'returns a hash of tokens' do
        allow(mock_response).to receive(:body).and_return(payload.to_json)

        expect(result).to eq(payload)
        expect(auth_service).to have_received(:response).with(an_instance_of(Net::HTTP::Post), an_instance_of(Net::HTTP))
      end
    end

    context 'when the request is unsuccessful' do
      it 'returns an empty hash' do
        allow(mock_response).to receive(:body).and_return({}.to_json)

        expect(result).to eq({})
        expect(auth_service).to have_received(:response).with(an_instance_of(Net::HTTP::Post), an_instance_of(Net::HTTP))
      end
    end
  end

  describe '#user_info' do
    let(:access_token) { 'mock_access_token' }
    let(:result) { auth_service.user_info(access_token) }

    context 'when the request is successful' do
      it 'returns a hash of user info' do
        allow(mock_response).to receive(:body).and_return(payload.to_json)

        expect(result).to eq(payload)
        expect(auth_service).to have_received(:response).with(an_instance_of(Net::HTTP::Get), an_instance_of(Net::HTTP))
      end
    end

    context 'when the request is unsuccessful' do
      it 'returns an empty hash' do
        allow(mock_response).to receive(:body).and_return({}.to_json)

        expect(result).to eq({})
        expect(auth_service).to have_received(:response).with(an_instance_of(Net::HTTP::Get), an_instance_of(Net::HTTP))
      end
    end
  end

  describe 'CALLBACKS' do
    it 'returns a frozen hash of callbacks urls' do
      expect(described_class::CALLBACKS).to eq({
        login: 'http://recovery.app/users/auth/openid_connect/callback',
        logout: 'http://recovery.app/users/sign_out',
      })

      expect(described_class::CALLBACKS).to be_frozen
    end
  end

  describe 'ENDPOINTS' do
    it 'returns a frozen hash of endpoints urls' do
      expect(described_class::ENDPOINTS).to eq({
        login: 'https://oidc.test.account.gov.uk/authorize',
        logout: 'https://oidc.test.account.gov.uk/logout',
        token: 'https://oidc.test.account.gov.uk/token',
        userinfo: 'https://oidc.test.account.gov.uk/userinfo',
        jwks: 'https://oidc.test.account.gov.uk/.well-known/jwks.json',
      })

      expect(described_class::ENDPOINTS).to be_frozen
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
      expect(jwt_payload[:aud]).to eq('https://oidc.test.account.gov.uk/token')
      expect(jwt_payload[:iss]).to be_a(String)
      expect(jwt_payload[:sub]).to be_a(String)
      expect(jwt_payload[:exp]).to be_between(Time.zone.now.to_i + 4 * 60, Time.zone.now.to_i + 6 * 60)
      expect(jwt_payload[:jti]).to be_a(String)
      expect(jwt_payload[:iat]).to be_a(Integer)
    end
  end
end
