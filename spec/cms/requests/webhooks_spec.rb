require 'rails_helper'

RSpec.describe 'Webhooks', :cms, type: :request do
  describe 'POST /webhooks' do
    specify do
      post '/webhooks'
      expect(response).to have_http_status(:success)
    end
  end
end
