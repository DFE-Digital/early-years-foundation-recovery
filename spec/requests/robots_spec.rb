require 'rails_helper'

RSpec.describe 'Web crawlers' do
  context 'when not in production environment' do
    it 'robots.txt exists' do
      get '/robots.txt'
      expect(response).to have_http_status(:success)
    end
  end

  context 'when in production environment' do
    before do
      ENV['WORKSPACE'] = 'production'
    end

    it 'robots.txt does not exist' do
      get '/robots.txt'
      expect(response).to have_http_status(:not_found)
    end
  end
end
