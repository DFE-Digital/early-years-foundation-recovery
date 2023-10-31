require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#openid_connect' do
    let(:auth_service) { instance_double(GovOneAuthService) }
    let(:access_token) { 'mock_access_token' }
    let(:id_token) { 'mock_id_token' }
    let(:email) { 'test@example.com' }

    before do
      allow(GovOneAuthService).to receive(:new).and_return(auth_service)
      allow(auth_service).to receive(:tokens).and_return({ 'access_token' => access_token, 'id_token' => id_token })
      allow(auth_service).to receive(:user_info).and_return({ 'email' => email })
      allow(auth_service).to receive(:jwt_assertion).and_return('mock_jwt_assertion')
      allow(auth_service).to receive(:decode_id_token).and_return([{ 'sub' => 'mock_sub' }])
      session[:gov_one_auth_state] = 'mock_state'
    end

    context 'when a User does not exist' do
      it 'creates the user with the email and id_token' do
        get :openid_connect, params: { 'code' => 'mock_code', 'state' => 'mock_state' }
        expect(User.find_by(email: email)).to be_truthy
        expect(User.find_by(gov_one_id: 'mock_sub')).to be_truthy
        expect(response).to redirect_to(edit_registration_name_path)
        expect(session[:id_token]).to eq(id_token)
      end
    end

    context 'when a User email exists' do
      before do
        create :user, :registered, email: email
      end

      it 'updates the user id_token and signs them in' do
        get :openid_connect, params: { 'code' => 'mock_code', 'state' => 'mock_state' }
        expect(User.find_by(gov_one_id: 'mock_sub')).to be_truthy
        expect(response).to redirect_to(my_modules_path)
        expect(session[:id_token]).to eq(id_token)
      end
    end

    context 'when a User id_token exists' do
      before do
        create :user, :registered, gov_one_id: 'mock_sub'
      end

      it 'signs the user in' do
        get :openid_connect, params: { 'code' => 'mock_code', 'state' => 'mock_state' }
        expect(response).to redirect_to(my_modules_path)
        expect(session[:id_token]).to eq(id_token)
      end
    end
  end
end
