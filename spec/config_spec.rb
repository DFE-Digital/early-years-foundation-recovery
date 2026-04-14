require 'rails_helper'

RSpec.describe 'Application configuration' do
  subject(:config) { EarlyYearsFoundationRecovery::Application.config }

  describe 'published content (stubbed preview)' do
    require 'support/contentful_stub_service'
    include_context 'when stub contentful for published tests'

    it 'tests against demo content' do
      expect(ContentfulRails.configuration.environment).to eq 'test'
      expect(config.contentful_environment).to eq 'test'
    end

    it 'tests against published content' do
      if ENV['CONTENTFUL_PREVIEW'] == 'true'
        expect(Rails.application).to be_preview
      else
        expect(Rails.application).not_to be_preview
      end
    end

    it 'authenticates using credentials' do
      expect(config.contentful_space).to be_present
      expect(config.contentful_delivery_access_token).to be_present
      expect(config.contentful_preview_access_token).to be_present
      expect(config.contentful_management_access_token).not_to be_present # user specific
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
