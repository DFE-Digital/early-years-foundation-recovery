require 'rails_helper'

RSpec.describe 'Webhooks', :cms, type: :request do
  describe 'POST /release' do
    it 'persists the latest release event' do
      expect(Release.count).to be 0
      payload = { sys: { id: 'release', completedAt: Time.zone.now } }
      post '/release', params: payload, as: :json
      expect(response).to have_http_status(:ok)
      expect(Release.last.name).to eql 'release'
    end
  end

  describe 'POST /change' do
    it 'persists the latest change event' do
      expect(Release.count).to be 0
      payload = { sys: { id: 'change', updatedAt: Time.zone.now } }
      post '/change', params: payload, as: :json
      expect(response).to have_http_status(:ok)
      expect(Release.last.name).to eql 'change'
    end
  end
end
