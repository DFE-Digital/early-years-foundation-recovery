require 'rails_helper'

RSpec.describe 'Production authentication configuration' do
  let(:config) do
    ActiveSupport::OrderedOptions.new.tap do |options|
      %i[action_controller action_dispatch action_mailer active_storage public_file_server assets active_support active_record i18n].each do |key|
        options[key] = ActiveSupport::OrderedOptions.new
      end
      options.service_url = 'https://review-app-pr-123.azurewebsites.net'
    end
  end
  let(:integration) { { base_uri: 'https://integration.example.com', private_key: 'integration-key', client_id: 'integration-client' } }
  let(:context) { Struct.new(:config, :credentials).new(config, { gov_one: { integration: integration } }) }

  before do
    stub_const('ENV', {
      'ENVIRONMENT' => 'development',
      'REVIEW_APP' => 'true',
      'GOV_ONE_PRIVATE_KEY' => 'review-key',
      'GOV_ONE_CLIENT_ID' => 'review-pr-123',
    })
    allow(Rails.application).to receive(:preview?).and_return(false)
    allow(Rails.application).to receive(:configure) { |&block| context.instance_eval(&block) }
  end

  def load_configuration
    load Rails.root.join('config/environments/production.rb')
  end

  it 'uses the review hostname and explicit credentials and disables email delivery' do
    load_configuration
    expect(config.gov_one_base_uri).to eq config.service_url
    expect(config.gov_one_private_key).to eq 'review-key'
    expect(config.gov_one_client_id).to eq 'review-pr-123'
    expect(config.action_mailer.perform_deliveries).to be false
  end

  it 'preserves the integration defaults for ordinary development deployments' do
    ENV.delete('REVIEW_APP')
    load_configuration
    expect(config.gov_one_base_uri).to eq integration[:base_uri]
    expect(config.gov_one_private_key).to eq integration[:private_key]
    expect(config.gov_one_client_id).to eq integration[:client_id]
  end

  %w[staging production].each do |environment|
    it "rejects simulator mode in #{environment}" do
      ENV['ENVIRONMENT'] = environment
      expect { load_configuration }.to raise_error(RuntimeError, 'Review apps must use the development environment')
    end
  end

  it 'requires explicit simulator credentials rather than falling back to integration credentials' do
    ENV.delete('GOV_ONE_PRIVATE_KEY')
    expect { load_configuration }.to raise_error(KeyError)
  end
end
