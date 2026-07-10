require 'rails_helper'

RSpec.describe 'Automated bot', type: :request do
  before do
    allow(Rails.configuration).to receive(:audit_bot_token).and_return('audit_token')
  end

  context 'with a valid audit header' do
    before do
      get '/audit', headers: { 'BOT' => 'audit_token' }
    end

    it 'can access the audit endpoint' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'BOT ACCESS GRANTED'
    end
  end

  context 'with an invalid audit header' do
    before do
      get '/audit', headers: { 'BOT' => 'foo' }
    end

    it 'is denied' do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'without header' do
    before do
      get '/audit'
    end

    it 'is denied' do
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'with a valid audit header on an authenticated page' do
    before do
      get user_path, headers: { 'BOT' => 'audit_token' }
    end

    it 'does not grant user session access' do
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'with a valid audit header on a registration page' do
    before do
      get edit_registration_name_path, headers: { 'BOT' => 'audit_token' }
    end

    it 'does not bypass registration authentication' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
