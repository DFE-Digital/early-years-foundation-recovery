require 'rails_helper'

RSpec.describe GovOneAuthService do
  let(:code) { 'mock_code' }
  let(:token_payload) { { 'access_token' => 'mock_access_token', 'id_token' => 'mock_id_token' } }
  let(:mock_response) { instance_double('response') }
  let(:auth_service) { described_class.new(code) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOV_ONE_REDIRECT_URI').and_return('mock_redirect_uri')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION_TYPE').and_return('mock_assertion_type')
    allow(ENV).to receive(:[]).with('GOV_ONE_BASE_URI').and_return('https://example.com')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ID').and_return('mock_client_id')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION').and_return('mock_client_assertion')
  end

  describe '#tokens' do
    let(:mock_net_http_post) { instance_double('Net::HTTP::Post', request: nil) }

    context 'when the request is successful' do
      it 'returns a hash of tokens' do
        allow(mock_response).to receive(:body).and_return(token_payload.to_json)
        allow(mock_response).to receive(:code).and_return(200)
        allow(mock_net_http_post).to receive(:request).and_return(mock_response)
        allow(Net::HTTP).to receive(:new).and_return(mock_net_http_post)

        result = auth_service.tokens

        expect(mock_net_http_post).to receive(:set_form_data).with({
          client_assertion: 'mock_client_assertion',
          client_assertion_type: 'mock_assertion_type',
          code: 'mock_code',
          grant_type: 'authorization_code',
          redirect_uri: 'mock_redirect_uri',
        })
        expect(result).to eq(token_payload)
      end
    end
  end

  describe '#user_info' do
    let(:access_token) { 'mock_access_token' }
    let(:user_info_payload) { { 'email' => 'test@test.com' } }
    let(:mock_net_http_get) { instance_double('Net::HTTP::Get', request: nil) }

    context 'when the request is successful' do
      it 'returns a hash of user info' do
        allow(mock_response).to receive(:body).and_return(user_info_payload.to_json)
        allow(mock_response).to receive(:code).and_return(200)
        allow(mock_net_http_get).to receive(:request).and_return(mock_response)
        allow(Net::HTTP).to receive(:new).and_return(mock_net_http_get)

        result = auth_service.user_info(access_token)

        expect(result).to eq(user_info_payload)
      end
    end
  end
end
