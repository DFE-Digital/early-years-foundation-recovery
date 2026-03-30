
require 'rails_helper'
require 'mock_contentful_service'

RSpec.describe 'Application configuration' do
  subject(:config) { EarlyYearsFoundationRecovery::Application.config }

  let(:mock_contentful) { MockContentfulService.new }

  it 'returns mock page data without Contentful' do
    page = mock_contentful.fetch_page('test-page')
    expect(page.title).to eq 'Test Page for test-page'
    expect(page.body).to include 'mock content'
  end

  it 'does not require Contentful credentials or ENV' do
    expect { mock_contentful.fetch_page('offline') }.not_to raise_error
  end

  it 'expires sessions after 24 hrs' do
    expect(config.timeout_in_minutes).to eq 1440
    expect(Devise.timeout_in.in_days).to eq 1.0
  end

  it 'sets time zone' do
    expect(config.time_zone).to eq 'UTC'
  end

  it 'sets password for seeds' do
    expect(config.user_password).to eq 'Str0ngPa$$w0rd12'
  end

  it 'exports dashboard statistics daily at midnight' do
    expect(config.dashboard_update_interval).to eq '0 0 */2 * *'
  end

  describe 'seeded users' do
    before do
      Dibber::Seeder.seed(:user, name_method: :email)
    end

    specify do
      expect(User.count).to eq 3
    end
  end

  describe 'pages accessible even when in maintenance mode' do
    specify do
      expect(config.protected_endpoints).to eq %w[
        /maintenance
        /health
        /change
        /release
        /notify
      ]
    end
  end
end
