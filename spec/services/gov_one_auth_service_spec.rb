require 'rails_helper'

RSpec.describe GovOneAuthService, type: :service do
  let(:code) { 'mock_code' }
  let(:access_token) { 'mock_access_token' }
  let(:id_token) { 'mock_id_token' }
  let(:user_info) { { 'email' => 'test@example.com' } }

  before do
    allow(ENV).to receive(:[]).with('GOV_ONE_REDIRECT_URI').and_return('http://example.com/callback')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION_TYPE').and_return('urn:ietf:params:oauth:client-assertion-type:jwt-bearer')
    allow(ENV).to receive(:[]).with('GOV_ONE_BASE_URI').and_return('http://gov-one-example.com')
    allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ID').and_return('your_client_id')

    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('public_key.pem').and_return('mock_public_key_content')
    allow(File).to receive(:read).with('private_key.pem').and_return('mock_private_key_content')

    allow(SecureRandom).to receive(:uuid).and_return('mock_uuid')

    @auth_service = described_class.new(code)
  end

  describe '#tokens' do
    it 'returns a hash with access_token and id_token' do
      allow(@auth_service).to receive(:jwt_assertion).and_return('mock_jwt_assertion')

      token_response = { 'access_token' => access_token, 'id_token' => id_token }

      http_double = instance_double(Net::HTTP, request: instance_double(Net::HTTPResponse, body: token_response.to_json))
      allow(@auth_service).to receive(:build_http).and_return(http_double)

      result = @auth_service.tokens

      expect(result).to be_a(Hash)
      expect(result['access_token']).to eq(access_token)
      expect(result['id_token']).to eq(id_token)
    end
  end

  describe '#user_info' do
    it 'returns user information hash' do
      http_double = instance_double(Net::HTTP, request: instance_double(Net::HTTPResponse, body: user_info.to_json))
      allow(@auth_service).to receive(:build_http).and_return(http_double)

      result = @auth_service.user_info(access_token)

      expect(result).to be_a(Hash)
      expect(result['email']).to eq('test@example.com')
    end
  end
end
