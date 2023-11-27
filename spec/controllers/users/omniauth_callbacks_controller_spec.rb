require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:auth_service) { instance_double(GovOneAuthService) }
  let(:access_token) { 'mock_access_token' }
  let(:id_token) { 'mock_id_token' }
  let(:decoded_id_token) { { 'sub' => 'mock_sub' } }
  let(:email) { 'test@example.com' }
  let(:params) do
    { 'code' => 'mock_code', 'state' => 'mock_state' }
  end

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    session[:gov_one_auth_state] = 'mock_state'
    session[:gov_one_auth_nonce] = 'mock_nonce'

    allow(GovOneAuthService).to receive(:new).and_return(auth_service)
    allow(auth_service).to receive(:tokens).and_return({ 'access_token' => access_token, 'id_token' => id_token })
    allow(auth_service).to receive(:user_info).and_return({ 'email' => email, 'sub' => 'mock_sub' })
    allow(auth_service).to receive(:jwt_assertion).and_return('mock_jwt_assertion')
    allow(auth_service).to receive(:decode_id_token).and_return([decoded_id_token])
    allow(auth_service).to receive(:valid_id_token?).and_return(true)
  end

  context 'with a new user' do
    before do
      get :openid_connect, params: params
    end

    it 'creates an account' do
      expect(User.find_by(email: email)).to be_truthy
      expect(User.find_by(gov_one_id: 'mock_sub')).to be_truthy
    end

    it 'redirects to complete registration' do
      expect(session[:id_token]).to eq decoded_id_token
      expect(response).to redirect_to edit_registration_terms_and_conditions_path
    end
  end

  context 'with an existing non-gov-one user' do
    before do
      create :user, :registered, email: email
      get :openid_connect, params: params
    end

    it 'updates the account' do
      expect(User.find_by(gov_one_id: 'mock_sub')).to be_truthy
    end

    it 'redirects to /my-modules' do
      expect(session[:id_token]).to eq decoded_id_token
      expect(response).to redirect_to my_modules_path
    end
  end

  context 'with an existing gov-one user' do
    before do
      create :user, :registered, gov_one_id: 'mock_sub'
      get :openid_connect, params: params
    end

    it 'redirects to /my-modules' do
      expect(session[:id_token]).to eq decoded_id_token
      expect(response).to redirect_to my_modules_path
    end
  end
end
