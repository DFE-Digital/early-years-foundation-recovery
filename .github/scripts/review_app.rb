require 'json'
require 'open3'
require 'securerandom'
require 'tempfile'
require 'tmpdir'
require 'uri'

module ReviewApp
  class CommandError < StandardError
  end

  def self.az(*args)
    stdout, stderr, status = Open3.capture3('az', *args, '--only-show-errors', '--output', 'json')
    warn stderr unless stderr.empty?
    raise CommandError, "Azure CLI failed with exit status #{status.exitstatus}" unless status.success?

    JSON.parse(stdout) unless stdout.strip.empty?
  end

  def self.write_json(directory, name, value)
    path = File.join(directory, name)
    File.open(path, File::WRONLY | File::CREAT | File::TRUNC, 0o600) do |file|
      file.write(JSON.generate(value))
    end
    path
  end

  def self.capture!(*command, stdin_data: nil)
    stdout, stderr, status = Open3.capture3(*command, stdin_data: stdin_data)
    warn stderr unless stderr.empty?
    raise CommandError, "#{command.first} failed with exit status #{status.exitstatus}" unless status.success?

    stdout
  end

  class Deployer
    def initialize(env: ENV)
      @env = env
      @slot = @env.fetch('PR_NUMBER')
      raise ArgumentError, 'PR_NUMBER must be pr-<positive PR number>' unless @slot.match?(/\Apr-[1-9]\d*\z/)

      @app = ['--resource-group',
              @env.fetch('AZURE_RESOURCE_GROUP'),
              '--name',
              @env.fetch('REVIEWAPP_NAME')]
      @target = [*@app, '--slot', @slot]
      @server = ['--resource-group',
                 @env.fetch('AZURE_RESOURCE_GROUP'),
                 '--server-name',
                 @env.fetch('POSTGRES_SERVER')]
    end

    def slots
      ReviewApp.az('webapp', 'deployment', 'slot', 'list', *@app)
    end

    def databases
      ReviewApp.az('postgres', 'flexible-server', 'db', 'list', *@server)
    end

    def exists?(resources)
      resources.any? { |resource| resource.fetch('name').split('/').last == @slot }
    end

    def cleanup
      failures = []
      %i[delete_slot delete_database].each do |operation|
        public_send(operation)
      rescue CommandError
        failures << operation
      end
      return if failures.empty?

      raise "Cleanup failed: #{failures.join(', ')}; rerun cleanup"
    end

    def delete_slot
      if exists?(slots)
        ReviewApp.az('webapp', 'deployment', 'slot', 'delete', *@target)
      else
        puts "Slot #{@slot} already absent"
      end
    end

    def delete_database
      if exists?(databases)
        ReviewApp.az('postgres', 'flexible-server', 'db', 'delete', *@server,
                     '--name', @slot, '--yes')
      else
        puts "Database #{@slot} already absent"
      end
    end

    def deploy(directory)
      parent = ReviewApp.az('webapp', 'show', *@app)
      plan = ReviewApp.az('appservice', 'plan', 'show', '--ids', parent.fetch('serverFarmId'))
      unless plan.dig('sku', 'capacity') == 1
        raise 'Review plan must have exactly one worker: simulator state is in memory'
      end

      existing_slots = slots
      unless exists?(databases)
        ReviewApp.az('postgres', 'flexible-server', 'db', 'create', *@server,
                     '--name', @slot)
      end
      ReviewApp.az('webapp', 'deployment', 'slot', 'create', *@target) unless exists?(existing_slots)
      ReviewApp.az('webapp', 'stop', *@target)
      hostname = ReviewApp.az('webapp', 'show', *@target).fetch('defaultHostName')
      base_url = "https://#{hostname}"
      client_id = "review-#{@slot}"
      private_key = ReviewApp.capture!(
        'openssl', 'genpkey', '-algorithm', 'RSA', '-pkeyopt', 'rsa_keygen_bits:2048'
      )
      public_key = ReviewApp.capture!('openssl', 'pkey', '-pubout', stdin_data: private_key)
      database_url = "postgresql://#{URI.encode_www_form_component(@env.fetch('PSQLFS_USERNAME'))}:" \
                     "#{URI.encode_www_form_component(@env.fetch('PSQLFS_PASSWORD'))}@" \
                     "#{@env.fetch('POSTGRES_SERVER')}.postgres.database.azure.com/#{@slot}?sslmode=require"

      settings = ReviewApp.az('webapp', 'config', 'appsettings', 'list', *@app)
                 .to_h { |setting| [setting.fetch('name'), setting.fetch('value')] }
      settings.merge!(
        'RAILS_ENV' => 'production', 'ENVIRONMENT' => 'review',
        'REVIEW_SLOT_NAME' => @slot,
        'RAILS_SERVE_STATIC_FILES' => 'true',
        'DOMAIN' => hostname, 'DATABASE_URL' => database_url,
        'GOV_ONE_SIMULATOR' => 'true', 'GOV_ONE_BASE_URI' => base_url,
        'GOV_ONE_CLIENT_ID' => client_id, 'GOV_ONE_PRIVATE_KEY' => private_key,
        'SECRET_KEY_BASE' => SecureRandom.hex(64),
        'DASHBOARD_UPDATE' => 'false', 'GOVUK_NOTIFY_API_KEY' => '',
        'GOOGLE_CLOUD_BUCKET' => '', 'MAINTENANCE' => 'false',
        'WEB_CONCURRENCY' => '1', 'PORT' => '3000',
        'WEBSITE_WARMUP_PATH' => '/health', 'WEBSITE_WARMUP_STATUSES' => '200',
        'WEBSITES_CONTAINER_START_TIME_LIMIT' => '720',
        'REVIEW_SIMULATOR_URL' => base_url, 'REVIEW_CLIENT_ID' => client_id,
        'REVIEW_PUBLIC_KEY' => public_key,
        'REVIEW_LOGIN_CALLBACK' => "#{base_url}/users/auth/openid_connect/callback",
        'REVIEW_LOGOUT_CALLBACK' => "#{base_url}/users/sign_out",
        'REVIEW_SIMULATOR_PORT' => '4001', 'REVIEW_INTERACTIVE_MODE' => 'true',
        'REVIEW_SCOPES' => 'openid,email', 'REVIEW_SIGNING_ALGORITHM' => 'ES256',
        'REVIEW_EMAIL' => 'review@example.com', 'REVIEW_SUB' => "#{@slot}-reviewer"
      )
      ReviewApp.az('webapp', 'config', 'appsettings', 'set', *@target,
                   '--slot-settings', "@#{ReviewApp.write_json(directory, 'settings.json', settings)}")
      ReviewApp.az('webapp', 'vnet-integration', 'add', *@target,
                   '--subnet', @env.fetch('AZURE_REVIEW_APP_SUBNET'), '--vnet', @env.fetch('AZURE_VNET'))
      parent_config = ReviewApp.az('webapp', 'config', 'show', *@app)
      inherited_config = parent_config.slice(
        'ftpsState', 'minTlsVersion', 'scmMinTlsVersion',
        'ipSecurityRestrictions', 'ipSecurityRestrictionsDefaultAction',
        'scmIpSecurityRestrictions', 'scmIpSecurityRestrictionsDefaultAction',
        'scmIpSecurityRestrictionsUseMain'
      ).merge(
        'numberOfWorkers' => 1, 'vnetRouteAllEnabled' => true,
        'healthCheckPath' => '/health', 'http20Enabled' => true, 'appCommandLine' => ''
      )
      ReviewApp.az('webapp', 'config', 'set', *@target,
                   '--linux-fx-version', 'sitecontainers', '--always-on', 'true',
                   '--generic-configurations', JSON.generate(inherited_config))
      simulator_environment = {
        'PORT' => 'REVIEW_SIMULATOR_PORT',
        'SIMULATOR_URL' => 'REVIEW_SIMULATOR_URL',
        'CLIENT_ID' => 'REVIEW_CLIENT_ID',
        'PUBLIC_KEY' => 'REVIEW_PUBLIC_KEY',
        'REDIRECT_URLS' => 'REVIEW_LOGIN_CALLBACK',
        'POST_LOGOUT_REDIRECT_URLS' => 'REVIEW_LOGOUT_CALLBACK',
        'INTERACTIVE_MODE' => 'REVIEW_INTERACTIVE_MODE',
        'SCOPES' => 'REVIEW_SCOPES',
        'ID_TOKEN_SIGNING_ALGORITHM' => 'REVIEW_SIGNING_ALGORITHM',
        'EMAIL' => 'REVIEW_EMAIL',
        'SUB' => 'REVIEW_SUB',
      }
      containers = [
        { 'name' => 'ingress',
          'properties' => {
            'image' => @env.fetch('INGRESS_IMAGE'),
            'isMain' => true,
            'targetPort' => '8080',
            'authType' => 'Anonymous',
          } },
        { 'name' => 'rails',
          'properties' => {
            'image' => @env.fetch('RAILS_IMAGE'),
            'isMain' => false,
            'targetPort' => '3000',
            'authType' => 'Anonymous',
            'environmentVariables' => [
              { 'name' => 'WEBSITE_SLOT_NAME', 'value' => 'REVIEW_SLOT_NAME' },
            ],
          } },
        { 'name' => 'simulator',
          'properties' => {
            'image' => 'ghcr.io/govuk-one-login/simulator:26.10.8',
            'isMain' => false,
            'targetPort' => '4001',
            'authType' => 'Anonymous',
            'environmentVariables' => simulator_environment.map { |name, value| { 'name' => name, 'value' => value } },
          } },
      ]
      ReviewApp.az('webapp', 'sitecontainers', 'create', *@target,
                   '--sitecontainers-spec-file', ReviewApp.write_json(directory, 'containers.json', containers))
      ReviewApp.az('webapp', 'log', 'config', *@target, '--docker-container-logging', 'filesystem')
      ReviewApp.az('webapp', 'start', *@target)
      File.open(@env.fetch('GITHUB_OUTPUT'), 'a') { |output| output.puts("url=#{base_url}") }
      puts "Deployed #{@env.fetch('RAILS_IMAGE')} to #{base_url}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    deployer = ReviewApp::Deployer.new
    case ARGV
    when %w[cleanup]
      deployer.cleanup
    when %w[deploy]
      Dir.mktmpdir('review-app-') { |directory| deployer.deploy(directory) }
    else
      abort 'Usage: review_app.rb deploy|cleanup'
    end
  rescue ReviewApp::CommandError => e
    warn "Azure/OpenSSL operation failed: #{e.message}"
    exit 1
  end
end
