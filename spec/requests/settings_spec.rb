require 'rails_helper'

RSpec.describe 'Settings', type: :request do
  specify { expect('/settings/cookie-policy').to be_successful }

  describe 'POST /settings' do
    it 'redirects back to a local page' do
      post settings_path, params: {
        track_analytics: 'true',
        request_path: '/about-training',
      }
      expect(response).to redirect_to('/about-training')
    end

    it 'falls back to settings for an external destination' do
      post settings_path, params: {
        track_analytics: 'true',
        request_path: '//test.com',
      }
      expect(response).to redirect_to(settings_path)
    end
  end
end
