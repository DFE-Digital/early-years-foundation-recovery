require 'rails_helper'
# require 'webmock/rspec'

RSpec.describe GovOneAuthService do
  skip 'wip' do
    let(:code) { 'mock_code' }
    let(:token_payload) { { 'access_token' => 'mock_access_token', 'id_token' => 'mock_id_token' } }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOV_ONE_REDIRECT_URI').and_return('mock_redirect_uri')
      allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION_TYPE').and_return('mock_assertion_type')
      allow(ENV).to receive(:[]).with('GOV_ONE_BASE_URI').and_return('https://example.com')
      allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ID').and_return('mock_client_id')
    end

    describe '#tokens' do
      it 'returns a hash of tokens' do
        stub_request(:post, 'https://example.com/token')
          .with(
            body: {
              grant_type: 'authorization_code',
              code: code,
              redirect_uri: 'mock_redirect_uri',
              client_assertion_type: 'mock_assertion_type',
              client_assertion: anything,
            },
            headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
          )
          .to_return(status: 200, body: token_payload.to_json)

        auth_service = described_class.new(code)
        tokens = auth_service.tokens
        expect(tokens).to eq(token_payload)
      end
    end

    describe '#user_info' do
      let(:access_token) { 'mock_access_token' }
      let(:user_info_payload) { { 'email' => 'test@test.com' } }

      it 'returns a hash of user info' do
        stub_request(:get, 'https://example.com/userinfo')
          .with(
            headers: { 'Authorization' => "Bearer #{access_token}" },
          )
          .to_return(status: 200, body: user_info_payload.to_json)

        auth_service = described_class.new(code)
        user_info = auth_service.user_info(access_token)
        expect(user_info).to eq(user_info_payload)
      end
    end
  end
end
