require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  describe 'GET settings/cookie_policy' do
    it 'renders successfully' do
      get setting_path(:cookie_policy)
      expect(response).to have_http_status(:success)
    end
  end
end
