require 'rails_helper'

RSpec.describe 'Automated bot', type: :request do
  let(:bot_email) { 'bot_token@example.com' }
  let(:bot_name) { 'Bot' }

  before do
    create :user, :registered, email: bot_email, first_name: bot_name
  end

  context 'with header' do
    before do
      get user_path, headers: { 'BOT' => 'bot_token' }
    end

    it 'is not redirected and can access secure pages' do
      expect(response).not_to redirect_to new_user_session_path
      expect(response.body).to include bot_name
    end
  end

  context 'with invalid header' do
    before do
      get user_path, headers: { 'BOT' => 'foo' }
    end

    it 'is redirected and can not access secure pages' do
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'without header' do
    before do
      get user_path
    end

    it 'is redirected and can not access secure pages' do
      expect(response).to redirect_to new_user_session_path
    end
  end
end
