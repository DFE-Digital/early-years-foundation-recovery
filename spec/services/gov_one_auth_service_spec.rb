require 'rails_helper'

RSpec.describe GovOneAuthService do
  let(:code) { 'mock_code' }
  let(:mock_response) { instance_double('response') }
  let(:auth_service) { described_class.new(code) }
  let(:mock_http) { instance_double('Sentry::Net::HTTP') }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOV_ONE_REDIRECT_URI').and_return('mock_redirect_uri')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION_TYPE').and_return('mock_assertion_type')
    allow(ENV).to receive(:[]).with('GOV_ONE_BASE_URI').and_return('https://example.com')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ID').and_return('mock_client_id')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION').and_return('mock_client_assertion')
    allow(mock_http).to receive(:request).and_return(mock_response)
    allow(Net::HTTP).to receive(:new).and_return(mock_http)
  end

  describe '#tokens' do
    let(:token_payload) { { 'access_token' => 'mock_access_token', 'id_token' => 'mock_id_token' } }

    context 'when the request is successful' do
      it 'returns a hash of tokens' do
        allow(mock_response).to receive(:body).and_return(token_payload.to_json)

        result = auth_service.tokens
        expect(result).to eq(token_payload)
      end
    end

    context 'when the request is unsuccessful' do
      it 'returns an empty hash' do
        allow(mock_response).to receive(:body).and_return({}.to_json)

        result = auth_service.tokens
        expect(result).to eq({})
      end
    end
  end

  describe '#user_info' do
    let(:access_token) { 'mock_access_token' }
    let(:user_info_payload) { { 'email' => 'test@test.com' } }

    context 'when the request is successful' do
      it 'returns a hash of user info' do
        allow(mock_response).to receive(:body).and_return(user_info_payload.to_json)

        result = auth_service.user_info(access_token)
        expect(result).to eq(user_info_payload)
      end
    end

    context 'when the request is unsuccessful' do
      it 'returns an empty hash' do
        allow(mock_response).to receive(:body).and_return({}.to_json)

        result = auth_service.user_info(access_token)
        expect(result).to eq({})
      end
    end
  end
end
