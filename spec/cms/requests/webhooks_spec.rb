require 'rails_helper'

RSpec.describe 'Webhooks', :cms, type: :request do
  before do
    skip 'WIP' unless Rails.application.cms?
  end

  let(:headers) do
    { 'BOT' => 'bot_token' }
  end

  let(:release) do
    { sys: { id: 'release', completedAt: Time.zone.now } }
  end

  let(:change) do
    { sys: { id: 'change', updatedAt: Time.zone.now } }
  end

  context 'when authenticated using secret header' do
    describe 'POST /release' do
      it 'persists the latest release event' do
        expect(Release.count).to be 0
        post '/release', params: release, as: :json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(Release.last.name).to eql 'release'
      end
    end

    describe 'POST /change' do
      it 'persists the latest change event' do
        expect(Release.count).to be 0
        post '/change', params: change, as: :json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(Release.last.name).to eql 'change'
      end
    end
  end

  context 'when unauthenticated' do
    describe 'POST /release' do
      it 'persists the latest release event' do
        expect(Release.count).to be 0
        post '/release', params: release, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(Release.count).to be 0
      end
    end

    describe 'POST /change' do
      it 'persists the latest change event' do
        expect(Release.count).to be 0
        post '/change', params: change, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(Release.count).to be 0
      end
    end
  end
end
