require 'rails_helper'

RSpec.describe 'Session timeout warning', type: :request do
  describe '#check' do
    context 'with an active session' do
      before do
        sign_in create(:user, :registered)
        get check_session_timeout_path
      end

      # lag may have lowered the counter when the assertion is made
      it 'reports seconds before timeout' do
        expect(response).to have_http_status(:success)
        expect(response.body).to eq('180' || '179')
      end

      it 'decreases over time' do
        travel_to 1.minute.from_now
        get check_session_timeout_path
        expect(response.body).to eq '120'
      end
    end

    context 'without an active session' do
      before do
        get check_session_timeout_path
      end

      it 'returns zero' do
        expect(response).to have_http_status(:success)
        expect(response.body).to eq '0'
      end
    end
  end

  describe '#extend' do
    context 'with an active session' do
      before do
        sign_in create(:user, :registered)
        get extend_session_path
      end

      # lag may have lowered the counter when the assertion is made
      it 'extends current session' do
        expect(response).to have_http_status(:success)
        expect(response.body).to eq('180' || '179')
      end
    end

    context 'without an active session' do
      before do
        get extend_session_path
      end

      it 'returns zero' do
        expect(response).to have_http_status(:success)
        expect(response.body).to eq '0'
      end
    end
  end
end
