require 'rails_helper'

RSpec.describe 'Application configuration' do
  subject(:config) { EarlyYearsFoundationRecovery::Application.config }

  it 'sets time zone' do
    expect(config.time_zone).to eq 'UTC'
  end

  it 'sets service name' do
    expect(config.service_name).to eq 'Early years child development training'
  end

  it 'sets email mailbox' do
    expect(config.internal_mailbox).to eq 'child-development.training@education.gov.uk'
  end

  it 'exports dashboard statistics daily at noon' do
    expect(config.dashboard_update_interval).to eq '0 12 * * *'
  end

  describe 'time out' do
    it 'sets interval in minutes' do
      expect(config.user_timeout_minutes).to eq 25
      expect(config.user_timeout_warning_minutes).to eq 20
      expect(config.user_timeout_modal_visible).to eq 5
    end
  end
end
