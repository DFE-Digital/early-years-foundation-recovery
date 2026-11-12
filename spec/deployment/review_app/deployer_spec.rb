require 'spec_helper'
require 'fileutils'
require_relative '../../../.github/scripts/review_app'
require_relative '../../../.github/scripts/check_review_sign_in'

RSpec.describe ReviewApp::Deployer do
  let(:directory) { Dir.mktmpdir }
  let(:env) do
    {
      'PR_NUMBER' => 'pr-123',
      'AZURE_RESOURCE_GROUP' => 'review-group',
      'REVIEWAPP_NAME' => 'review-app',
      'POSTGRES_SERVER' => 'review-db',
      'PSQLFS_USERNAME' => 'test@example',
      'PSQLFS_PASSWORD' => 'test/p@ss',
      'AZURE_REVIEW_APP_SUBNET' => 'review-subnet',
      'AZURE_VNET' => 'review-vnet',
      'INGRESS_IMAGE' => 'example/ingress:sha',
      'RAILS_IMAGE' => 'example/rails:sha',
      'GITHUB_OUTPUT' => File.join(directory, 'output'),
    }
  end
  let(:deployer) { described_class.new(env: env) }
  let(:state) { {} }

  before do
    state.merge!(resources: [], calls: [], capacity: 1, failure: nil)
    allow(ReviewApp).to receive(:az) do |*args|
      state[:calls] << args
      if state[:failure] && args.first(state[:failure].length) == state[:failure]
        raise ReviewApp::CommandError, 'Azure CLI failed'
      end

      case args.first(4)
      when %w[webapp deployment slot list]
        state[:resources]
      when %w[postgres flexible-server db list]
        state[:resources]
      else
        case args.first(3)
        when %w[webapp show --resource-group]
          { 'serverFarmId' => 'plan-id', 'defaultHostName' => "review-app-#{env.fetch('PR_NUMBER')}.azurewebsites.net" }
        when %w[appservice plan show]
          { 'sku' => { 'capacity' => state[:capacity] } }
        when %w[webapp config appsettings]
          if args[3] == 'list'
            [
              { 'name' => 'CONTENTFUL_ENVIRONMENT', 'value' => 'review-content' },
              { 'name' => 'DATABASE_URL', 'value' => 'parent-database-must-not-be-used' },
            ]
          end
        when %w[webapp config show]
          { 'minTlsVersion' => '1.2', 'ipSecurityRestrictionsDefaultAction' => 'Deny' }
        end
      end
    end
  end

  after do
    FileUtils.remove_entry(directory) if File.directory?(directory)
  end

  def deploy
    allow(ReviewApp).to receive(:capture!).and_return("generated-review-only-key\n", "generated-public-key\n")
    deployer.deploy(directory)
    [
      JSON.parse(File.read(File.join(directory, 'settings.json'))),
      JSON.parse(File.read(File.join(directory, 'containers.json'))),
    ]
  end

  it 'creates slot-scoped settings and pinned sidecars for the requested commit' do
    settings, containers = deploy
    mutations = state[:calls].select do |call|
      (call.first(2) == %w[webapp config] && call.include?('set')) ||
        [%w[webapp sitecontainers], %w[webapp vnet-integration]].include?(call.first(2))
    end
    expect(mutations).not_to be_empty
    expect(mutations).to all(include('--slot', 'pr-123'))
    expect(settings.fetch('DATABASE_URL')).to include('test%40example:test%2Fp%40ss@', '/pr-123?')
    expect(settings).to include(
      'CONTENTFUL_ENVIRONMENT' => 'review-content',
      'ENVIRONMENT' => 'review',
      'REVIEW_SLOT_NAME' => 'pr-123',
      'RAILS_SERVE_STATIC_FILES' => 'true',
      'GOV_ONE_CLIENT_ID' => 'review-pr-123',
      'DASHBOARD_UPDATE' => 'false',
      'GOVUK_NOTIFY_API_KEY' => '',
    )
    expect(settings.fetch('GOV_ONE_BASE_URI')).to eq("https://#{settings.fetch('DOMAIN')}")
    expect(settings.fetch('REVIEW_LOGIN_CALLBACK')).to eq("#{settings.fetch('GOV_ONE_BASE_URI')}/users/auth/openid_connect/callback")
    expect(settings.fetch('REVIEW_LOGOUT_CALLBACK')).to eq("#{settings.fetch('GOV_ONE_BASE_URI')}/users/sign_out")
    expect(state[:calls].find { |call| call.first(4) == %w[postgres flexible-server db create] }).to include('--name', 'pr-123')
    create_slot = state[:calls].find { |call| call.first(4) == %w[webapp deployment slot create] }
    expect(create_slot).not_to include('--configuration-source')

    config_call = state[:calls].find { |call| call.first(3) == %w[webapp config set] }
    config = JSON.parse(config_call.fetch(config_call.index('--generic-configurations') + 1))
    expect(config).to include(
      'ipSecurityRestrictionsDefaultAction' => 'Deny',
      'healthCheckPath' => '/health',
      'numberOfWorkers' => 1,
    )
    expect(containers.filter_map { |container| container.fetch('name') if container.dig('properties', 'isMain') })
      .to eq(%w[ingress])
    expect(containers[1].dig('properties', 'image')).to eq('example/rails:sha')
    expect(containers[1].dig('properties', 'environmentVariables')).to include(
      { 'name' => 'WEBSITE_SLOT_NAME', 'value' => 'REVIEW_SLOT_NAME' },
    )
    logging_call = state[:calls].find { |call| call.first(3) == %w[webapp log config] }
    expect(logging_call).to include('--slot', 'pr-123', '--docker-container-logging', 'filesystem')
    expect(containers[2].dig('properties', 'image')).to eq('ghcr.io/govuk-one-login/simulator:26.10.8')
    expect(containers[2].dig('properties', 'environmentVariables')).to include(
      { 'name' => 'PORT', 'value' => 'REVIEW_SIMULATOR_PORT' },
      { 'name' => 'INTERACTIVE_MODE', 'value' => 'REVIEW_INTERACTIVE_MODE' },
    )
    expect(File.stat(File.join(directory, 'settings.json')).mode & 0o777).to eq(0o600)
  end

  it 'uses the current images for updates without recreating the slot' do
    env['RAILS_IMAGE'] = 'example/rails:new-sha'
    state[:resources] = [{ 'name' => 'pr-123' }]
    _, containers = deploy
    expect(state[:calls].any? { |call| call.first(4) == %w[webapp deployment slot create] }).to be(false)
    expect(containers[1].dig('properties', 'image')).to eq('example/rails:new-sha')
  end

  it 'uses distinct database, client ID, hostname and session secret per PR' do
    first, = deploy
    env['PR_NUMBER'] = 'pr-456'
    allow(ReviewApp).to receive(:capture!).and_return("generated-review-only-key\n", "generated-public-key\n")
    described_class.new(env: env).deploy(directory)
    second = JSON.parse(File.read(File.join(directory, 'settings.json')))
    %w[DATABASE_URL GOV_ONE_CLIENT_ID DOMAIN SECRET_KEY_BASE].each do |key|
      expect(first.fetch(key)).not_to eq(second.fetch(key))
    end
  end

  it 'refuses a review plan with multiple workers before making changes' do
    state[:capacity] = 2

    expect { deployer.deploy(directory) }.to raise_error(/exactly one worker/)
    expect(state[:calls].length).to eq(2)
  end

  it 'makes cleanup safe to repeat when both resources are absent' do
    expect { 2.times { deployer.cleanup } }.not_to raise_error
    expect(state[:calls].none? { |call| call.include?('delete') }).to be(true)
  end

  it 'deletes the database by its supported CLI name option' do
    state[:resources] = [{ 'name' => 'review-app/pr-123' }, { 'name' => 'pr-123' }]
    deployer.cleanup

    database_delete = state[:calls].find { |call| call.first(4) == %w[postgres flexible-server db delete] }
    expect(database_delete).to include('--name', 'pr-123', '--yes')
    expect(state[:calls].count { |call| call.include?('delete') }).to eq(2)
  end

  it 'cleans up a database left by a partial deployment' do
    state[:resources] = [{ 'name' => 'pr-123' }]
    allow(deployer).to receive(:slots).and_return([])
    deployer.cleanup
    expect(state[:calls].count { |call| call.include?('delete') }).to eq(1)
  end

  it 'attempts database cleanup when slot deletion fails' do
    state[:resources] = [{ 'name' => 'pr-123' }]
    state[:failure] = %w[webapp deployment slot delete]
    expect { deployer.cleanup }.to raise_error(/delete_slot/)
    expect(state[:calls].any? { |call| call.first(4) == %w[postgres flexible-server db delete] }).to be(true)
  end

  it 'reports permission errors instead of treating resources as absent' do
    state[:failure] = %w[webapp deployment slot list]
    expect { deployer.cleanup }.to raise_error(/delete_slot/)
    expect(state[:calls].none? { |call| call.first(4) == %w[webapp deployment slot delete] }).to be(true)
  end

  it 'leaves a slot stopped when settings fail' do
    state[:failure] = %w[webapp config appsettings set]
    expect { deployer.deploy(directory) }.to raise_error(ReviewApp::CommandError)
    expect(state[:calls].any? { |call| call.first(2) == %w[webapp stop] }).to be(true)
    expect(state[:calls].any? { |call| call.first(2) == %w[webapp start] }).to be(false)
  end

  it 'rejects names that are not PR slots' do
    %w[production staging pr-0 pr-123/other].each do |slot|
      expect { described_class.new(env: env.merge('PR_NUMBER' => slot)) }.to raise_error(ArgumentError)
    end
  end

  describe 'review sign-in smoke check' do
    let(:base_url) { 'https://review-pr-123.azurewebsites.net' }
    let(:page) do
      %(<a href="#{base_url}/authorize?client_id=review-pr-123&amp;redirect_uri=#{base_url}/users/auth/openid_connect/callback&amp;response_type=code">Continue</a>)
    end

    it 'accepts the exact review host, callback and OIDC parameters' do
      expect(check_review_sign_in(page, base_url)).to be(true)
    end

    it 'rejects another host or callback' do
      expect { check_review_sign_in(page.sub(base_url, "#{base_url}.attacker.example"), base_url) }
        .to raise_error(ArgumentError)
      expect { check_review_sign_in(page.sub('/users/auth/openid_connect/callback', '/other'), base_url) }
        .to raise_error(ArgumentError)
    end

    it 'rejects missing OIDC parameters or an invalid client ID' do
      expect { check_review_sign_in(page.sub('&amp;response_type=code', ''), base_url) }
        .to raise_error(ArgumentError)
      expect { check_review_sign_in(page.sub('review-pr-123', 'review-pr-invalid'), base_url) }
        .to raise_error(ArgumentError)
    end
  end
end
