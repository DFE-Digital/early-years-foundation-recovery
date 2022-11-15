require 'rails_helper'

RSpec.describe SessionExtendController, type: :controller do
  # Using a controller spec as need to access session to test extend session endpoint
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'user extend session' do
    before do
      sign_in create(:user, :registered)
    end

    it 'allows user to extend their user session' do
      get :extend_session
      expect(response).to have_http_status(:success)
    end
  end
end
