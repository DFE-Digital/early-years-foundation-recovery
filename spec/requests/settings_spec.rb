require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  specify { expect('/settings/cookie-policy').to be_successful }

  describe 'POST /settings' do
    it 'redirects to an internal request path' do
      post settings_path, params: { request_path: '/settings/cookie-policy', track_analytics: 'true' }

      expect(response).to redirect_to('/settings/cookie-policy')
    end

    it 'falls back to the homepage when the request path is protocol-relative' do
      post settings_path, params: { request_path: '//evil.test', track_analytics: 'true' }

      expect(response).to redirect_to(root_path)
    end
  end
end
