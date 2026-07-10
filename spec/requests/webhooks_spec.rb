require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  let(:release) do
    { sys: { id: 'release', completedAt: Time.zone.now } }
  end

  let(:change) do
    { sys: { id: 'change', updatedAt: Time.zone.now } }
  end

  let(:notify) do
    {
      to: user.email,
      template: 'foo',
      notification_type: 'email',
      status: 'delivered',
    }
  end

  before do
    Rails.cache.clear

    allow(Rails.configuration).to receive_messages(contentful_webhook_token: 'contentful_token', notify_webhook_token: 'notify_token')

    # stub the Resource class to avoid loading it from the database
    stub_const('Resource', Class.new do
      def self.reset_cache_key!; end
    end)
    allow(Resource).to receive(:reset_cache_key!)
    allow(Page).to receive(:reset_cache_key!)
  end

  after do
    Rails.cache.clear
  end

  context 'when authenticated using secret header' do
    let(:headers) do
      { 'BOT' => 'contentful_token' }
    end

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
        { 'Authorization' => 'Bearer notify_token' }
      end

      let(:user) { create :user }

      before do
        user.mail_events.create!(template: 'foo')
      end

      it 'persists the callback' do
        post '/notify', params: notify, as: :json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(User.email_status('delivered')).to include user.reload
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
      let(:user) { create :user }

      it 'is denied' do
        post '/notify', params: notify, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(User.last.notify_callback).to be_nil
      end
    end
  end

  context 'when many invalid attempts happen from the same client' do
    describe 'POST /release' do
      let(:valid_headers) { { 'BOT' => 'contentful_token' } }
      let(:invalid_headers) { { 'BOT' => 'invalid_token' } }

      it 'still allows a valid token after the failed-attempt threshold' do
        25.times do
          post '/release', params: release, as: :json, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized).or have_http_status(:too_many_requests)
        end

        post '/release', params: release, as: :json, headers: valid_headers
        expect(response).to have_http_status(:ok)
      end

      it 'resets the failed-attempt counter after a valid request' do
        19.times do
          post '/release', params: release, as: :json, headers: invalid_headers
          expect(response).to have_http_status(:unauthorized)
        end

        post '/release', params: release, as: :json, headers: valid_headers
        expect(response).to have_http_status(:ok)

        post '/release', params: release, as: :json, headers: invalid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
