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
    end

    context 'when a User does not exist' do
      it 'sets session id_token and creates the user' do
        get :openid_connect, params: { 'code' => 'mock_code' }
        expect(session[:id_token]).to eq(id_token)
        expect(User.find_by(email: email)).to be_truthy
        expect(response).to redirect_to(edit_registration_name_path)
      end
    end

    context 'when a User exists' do
      before do
        create :user, :registered, email: email
      end

      it 'sets session id_token and signs in the user' do
        get :openid_connect, params: { 'code' => 'mock_code' }
        expect(session[:id_token]).to eq(id_token)
        expect(response).to redirect_to(my_modules_path)
      end
    end
  end
end
