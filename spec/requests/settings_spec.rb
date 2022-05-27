require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  describe 'GET settings/cookie-policy' do
    it 'renders successfully' do
      get '/settings/cookie-policy'
      expect(response).to have_http_status(:success)
    end
  end
end
