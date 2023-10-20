require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  describe '#openid_connect' do
    let(:auth_service) { instance_double(GovOneAuthService) }
    let(:access_token) { 'mock_access_token' }
    let(:id_token) { 'mock_id_token' }
    let(:email) { 'test@example.com' }

    before do
      allow(GovOneAuthService).to receive(:new).and_return(auth_service)
      allow(auth_service).to receive(:tokens).and_return('access_token' => access_token, 'id_token' => id_token)
      allow(auth_service).to receive(:user_info).with(access_token).and_return('email' => email)
    end

    it 'sets session id_token and finds or creates the user' do
      get :openid_connect, params: { 'code' => 'mock_code' }

      expect(session[:id_token]).to eq(id_token)
      expect(assigns(:email)).to eq(email)
      expect(response).to redirect_to(root_path)
    end

    it 'signs in and redirects the user if found or created' do
      user = create(:user, email: email) # Assuming you have a User model and FactoryBot

      allow(controller).to receive(:find_or_create_user).and_return(user)

      get :openid_connect, params: { 'code' => 'mock_code' }

      expect(response).to redirect_to(root_path) # Adjust the path based on your actual redirect path
      expect(subject.current_user).to eq(user)
    end

    it 'does not sign in if user is not found or created' do
      allow(controller).to receive(:find_or_create_user).and_return(nil)

      get :openid_connect, params: { 'code' => 'mock_code' }

      expect(response).to redirect_to(root_path) # Adjust the path based on your actual redirect path
      expect(subject.current_user).to be_nil
    end
  end
end
