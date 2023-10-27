require 'rails_helper'

RSpec.describe GovOneAuthService do
    let(:code) { 'mock_code' }
    let(:token_payload) { { 'access_token' => 'mock_access_token', 'id_token' => 'mock_id_token' } }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOV_ONE_REDIRECT_URI').and_return('mock_redirect_uri')
      allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION_TYPE').and_return('mock_assertion_type')
      allow(ENV).to receive(:[]).with('GOV_ONE_BASE_URI').and_return('https://example.com')
      allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ID').and_return('mock_client_id')
      allow(ENV).to receive(:[]).with('GOV_ONE_CLIENT_ASSERTION').and_return('mock_client_assertion')
    end

    describe '#tokens' do
      it 'returns a hash of tokens' do
        mock_response = double('response')
        allow(mock_response).to receive(:body).and_return(token_payload.to_json)
        allow(mock_response).to receive(:code).and_return(200)
    
        mock_net_http_post = double("Net::HTTP::Post")
        allow(Net::HTTP).to receive(:new).and_return(mock_net_http_post)
        allow(mock_net_http_post).to receive(:use_ssl=).with(true)
    
        allow(Net::HTTP::Post).to receive(:new).and_return(mock_net_http_post)

        expect(mock_net_http_post).to receive(:set_form_data).with({
          :client_assertion => "mock_client_assertion",
          :client_assertion_type => "mock_assertion_type",
          :code => "mock_code",
          :grant_type => "authorization_code",
          :redirect_uri => "mock_redirect_uri"
        })
        allow(mock_net_http_post).to receive(:request).and_return(mock_response)
        expect(described_class.new(code).tokens).to eq(token_payload)

      end
    end
    

    describe '#user_info' do
      it 'returns a hash of user info' do
      let(:access_token) { 'mock_access_token' }
      let(:user_info_payload) { { 'email' => 'test@test.com' } }
      mock_response = double('response')
      allow(mock_response).to receive(:body).and_return(user_info_payload.to_json)
      allow(mock_response).to receive(:code).and_return(200)

      mock_net_http_get = double("Net::HTTP::Get")
      allow(Net::HTTP).to receive(:new).and_return(mock_net_http_get)
      allow(mock_net_http_get).to receive(:use_ssl=).with(true)

      allow(Net::HTTP::Get).to receive(:new).and_return(mock_net_http_get)

      allow(mock_net_http_get).to receive(:request).and_return(mock_response)
      expect(described_class.new(code).user_info(access_token)).to eq(user_info_payload)

    end
  end

end
