require 'rails_helper'

RSpec.describe 'Application configuration' do
  subject(:config) { EarlyYearsFoundationRecovery::Application.config }

  it 'tests against demo content' do
    expect(ContentfulRails.configuration.environment).to eq 'test'
    expect(config.contentful_environment).to eq 'test'
  end

  # Uncomment this when feedback forms have been published
  it 'tests against published content' do
    skip 'feedback wip'
    expect(Rails.application).not_to be_preview
  end

  it 'authenticates using credentials' do
    expect(config.contentful_space).to be_present
    expect(config.contentful_delivery_access_token).to be_present
    expect(config.contentful_preview_access_token).to be_present
    expect(config.contentful_management_access_token).not_to be_present # user specific
  end

  it 'sets time zone' do
    expect(config.time_zone).to eq 'UTC'
  end

  it 'sets password for seeds' do
    expect(config.user_password).to eq 'Str0ngPa$$w0rd12'
  end

  it 'exports dashboard statistics daily at midnight' do
    expect(config.dashboard_update_interval).to eq '0 0 * * *'
  end

  describe 'seeded users' do
    before do
      Dibber::Seeder.seed(:user, name_method: :email)
    end

    specify do
      expect(User.count).to eq 3
    end
  end

  describe 'time out' do
    it 'sets interval in minutes' do
      expect(config.user_timeout_minutes).to eq 25
      expect(config.user_timeout_warning_minutes).to eq 20
      expect(config.user_timeout_modal_visible).to eq 5
    end
  end
end
