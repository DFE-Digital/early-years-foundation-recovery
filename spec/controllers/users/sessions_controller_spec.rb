require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    get :openid_connect, params: { 'code' => 'mock_code' }
  end

  let(:auth_service) { instance_double(GovOneAuthService) }
  let(:access_token) { 'mock_access_token' }
  let(:id_token) { 'mock_id_token' }
  let(:email) { 'test@example.com' }

  before do
    allow(GovOneAuthService).to receive(:new).and_return(auth_service)
    allow(auth_service).to receive(:tokens).and_return('access_token' => access_token, 'id_token' => id_token)
    allow(auth_service).to receive(:user_info).with(access_token).and_return('email' => email)
  end

  context 'when user is found or created' do
    let(:user) { create(:user, email: email) }

    before do
      allow(controller).to receive(:find_or_create_user).and_return(user)
    end

    it 'sets session id_token' do
      expect(session[:id_token]).to eq(id_token)
    end

    it 'signs in the user and redirects to root path' do
      expect(response).to redirect_to(root_path)
      expect(subject.current_user).to eq(user)
    end
  end

  context 'when user is not found or created' do
    before do
      allow(controller).to receive(:find_or_create_user).and_return(nil)
    end

    it 'does not sign in and redirects to root path' do
      expect(response).to redirect_to(sign_in_path)
      expect(subject.current_user).to be_nil
    end
  end
end
