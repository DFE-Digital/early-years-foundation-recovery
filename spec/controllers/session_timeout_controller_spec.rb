require 'rails_helper'

RSpec.describe SessionTimeoutController, type: :controller do
  # Using a controller spec as need to access session to test extend session endpoint
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'user session status' do
    before do
      sign_in create(:user, :registered)
    end

    it 'allows user to check remaining user session timeout period' do
      get :check_session_timeout
      expect(response).to have_http_status(:success)
    end
  end
end
