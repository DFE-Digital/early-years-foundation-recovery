require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'not found' do
    it 'returns http success' do
      get '/404'
      expect(response).to have_http_status(:success)
    end
  end
end
