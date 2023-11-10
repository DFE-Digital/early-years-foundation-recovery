require 'rails_helper'

RSpec.shared_examples 'an unsuccessful request' do
  it 'returns an empty hash' do
    allow(mock_response).to receive(:body).and_return({}.to_json)
    expect(result).to eq({})
  end
end

RSpec.shared_examples 'a successful request' do
  it 'returns a hash of user data' do
    allow(mock_response).to receive(:body).and_return(payload.to_json)
    expect(result).to eq(payload)
  end
end

RSpec.describe GovOneAuthService do
  let(:code) { 'mock_code' }
  let(:mock_response) { instance_double('response') }
  let(:auth_service) { described_class.new(code: code) }
  let(:mock_http) { instance_double('Sentry::Net::HTTP') }

  before do
    allow(mock_http).to receive(:request).and_return(mock_response)
    allow(Net::HTTP).to receive(:new).and_return(mock_http)
  end

  describe '#tokens' do
    let(:payload) { { 'access_token' => 'mock_access_token', 'id_token' => 'mock_id_token' } }
    let(:result) { auth_service.tokens }

    context 'when the request is successful' do
      it_behaves_like 'a successful request'
    end

    context 'when the request is unsuccessful' do
      it_behaves_like 'an unsuccessful request'
    end
  end

  describe '#user_info' do
    let(:access_token) { 'mock_access_token' }
    let(:payload) { { 'email' => 'test@test.com' } }
    let(:result) { auth_service.user_info(access_token) }

    context 'when the request is successful' do
      it_behaves_like 'a successful request'
    end

    context 'when the request is unsuccessful' do
      it_behaves_like 'an unsuccessful request'
    end
  end
end
