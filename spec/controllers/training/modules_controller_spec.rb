require 'rails_helper'

RSpec.describe Training::ModulesController, type: :controller do
  # Using a controller spec as need to access session to test timeout
  describe 'user timeout' do
    before do
      sign_in create(:user, :registered)
    end

    it 'allows user to access target page' do
      get :show, params: { id: 'alpha' }
      expect(response).to have_http_status(:success)
    end

    context 'when session has timed out' do
      let(:timeout) do
        Rails.configuration.user_timeout_minutes.minutes + 1.second
      end

      it 'redirects to timeout error' do
        get :show, params: { id: 'alpha' }, session: {
          'warden.user.user.session' => {
            'last_request_at' => timeout.ago,
          },
        }
        expect(response).to redirect_to users_timeout_path
      end
    end
  end
end
