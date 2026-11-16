require 'spec_helper'
require_relative '../../lib/review_app_configuration'

RSpec.describe ReviewAppConfiguration do
  subject(:enabled) { described_class.enabled?(environment) }

  let(:environment) do
    {
      'GOV_ONE_SIMULATOR' => 'true',
      'ENVIRONMENT' => 'review',
      'WEBSITE_SLOT_NAME' => 'pr-123',
      'DOMAIN' => 'example.azurewebsites.net',
      'GOV_ONE_BASE_URI' => 'https://example.azurewebsites.net',
      'GOV_ONE_PRIVATE_KEY' => 'review-key',
      'GOV_ONE_CLIENT_ID' => 'review-pr-123',
    }
  end

  it 'allows simulator authentication in a review slot with the production Rails runtime' do
    environment['RAILS_ENV'] = 'production'
    expect(enabled).to be true
  end

  %w[staging production development].each do |name|
    it "rejects enabling the simulator in #{name}" do
      environment['ENVIRONMENT'] = name
      expect { enabled }.to raise_error(/only permitted/)
    end
  end

  it 'rejects non-PR slots' do
    environment['WEBSITE_SLOT_NAME'] = 'staging'
    expect { enabled }.to raise_error(/only permitted/)
  end

  it 'requires an explicit simulator opt-in for review' do
    environment.delete('GOV_ONE_SIMULATOR')
    expect { enabled }.to raise_error(/only permitted/)
  end

  it 'rejects another issuer' do
    environment['GOV_ONE_BASE_URI'] = 'https://another.azurewebsites.net'
    expect { enabled }.to raise_error(/HTTPS hostname/)
  end

  it 'requires dedicated signing credentials' do
    environment.delete('GOV_ONE_PRIVATE_KEY')
    expect { enabled }.to raise_error(KeyError)
  end

  it 'rejects an empty signing key' do
    environment['GOV_ONE_PRIVATE_KEY'] = ''
    expect { enabled }.to raise_error(/must not be empty/)
  end

  it 'rejects a client ID from another slot' do
    environment['GOV_ONE_CLIENT_ID'] = 'review-pr-456'
    expect { enabled }.to raise_error(/unique to the PR slot/)
  end

  it 'leaves other environments unchanged when simulator mode is off' do
    expect(described_class.enabled?({ 'ENVIRONMENT' => 'production' })).to be false
  end
end
