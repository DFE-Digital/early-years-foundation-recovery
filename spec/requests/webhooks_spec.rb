require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  let(:headers) do
    { 'BOT' => 'bot_token' }
  end

  let(:release) do
    { sys: { id: 'release', completedAt: Time.zone.now } }
  end

  let(:change) do
    { sys: { id: 'change', updatedAt: Time.zone.now } }
  end

  let(:notify) do
    { 'to' => create(:user).email }
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

    describe 'POST /notify' do
      let(:headers) do
        { 'Authorization' => 'Bearer token: bot_token' }
      end

      it 'persists the callback' do
        post '/notify', params: notify, as: :json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(User.last.notify_callback).to eq notify
      end
    end
  end

  context 'when unauthenticated' do
    describe 'POST /release' do
      it 'is denied' do
        expect(Release.count).to be 0
        post '/release', params: release, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(Release.count).to be 0
      end
    end

    describe 'POST /change' do
      it 'is denied' do
        expect(Release.count).to be 0
        post '/change', params: change, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(Release.count).to be 0
      end
    end

    describe 'POST /notify' do
      it 'is denied' do
        post '/notify', params: notify, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(User.last.notify_callback).to be_nil
      end
    end
  end
end
