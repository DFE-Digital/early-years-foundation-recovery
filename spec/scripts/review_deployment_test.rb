require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'json'
require 'openssl'

class ReviewDeploymentTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)

  def setup
    @dir = Dir.mktmpdir('review-deployment-test')
    @env = {
      'PATH' => "#{@dir}:#{ENV.fetch('PATH')}",
      'AZ_LOG' => File.join(@dir, 'commands.jsonl'),
      'RESOURCE_GROUP' => 'development-rg',
      'REVIEWAPP_NAME' => 'review-app',
      'PR_NUMBER' => 'pr-123',
      'RESOURCE_NAME_PREFIX' => 'development',
      'DOCKER_IMAGE' => 'ghcr.io/example/app',
      'IMAGE_SHA' => 'abc123',
      'PSQLFS_USERNAME' => 'review@user',
      'PSQLFS_PASSWORD' => 'fake/password?#',
      'REVIEW_APP_SUBNET' => 'review-subnet',
      'AZURE_VNET' => 'development-vnet',
    }
    File.write(File.join(@dir, 'az'), <<~'RUBY')
      #!/usr/bin/env ruby
      require 'json'
      args = ARGV
      record = { 'args' => args }
      %w[--body --slot-settings].each do |flag|
        index = args.index(flag)
        record['body'] = JSON.parse(File.read(args[index + 1].delete_prefix('@'))) if index
      end
      File.open(ENV.fetch('AZ_LOG'), 'a') { |file| file.puts(JSON.generate(record)) }
      if ENV['AZ_FAIL'] && args.first(ENV['AZ_FAIL'].split.length).join(' ') == ENV['AZ_FAIL']
        warn 'Azure operation failed'
        exit 3
      end
      case args.first(4)
      when %w[webapp deployment slot list]
        puts ENV.fetch('EXISTING_SLOTS', '')
      when %w[postgres flexible-server db list]
        puts ENV.fetch('EXISTING_DATABASES', '')
      when %w[appservice plan show --ids]
        puts ENV.fetch('PLAN_CAPACITY', '1')
      end
      puts '/subscriptions/test/resourceGroups/development-rg/providers/Microsoft.Web/sites/review-app/slots/pr-123' if args.first(2) == %w[webapp show]
    RUBY
    File.write(File.join(@dir, 'curl'), <<~'SH')
      #!/usr/bin/env bash
      printf '%s' "$SMOKE_PAGE"
    SH
    FileUtils.chmod(0o755, [File.join(@dir, 'az'), File.join(@dir, 'curl')])
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def run_script(name, *args)
    Open3.capture3(@env, 'bash', File.join(ROOT, '.github/scripts', name), *args)
  end

  def commands
    File.readlines(@env.fetch('AZ_LOG')).map { |line| JSON.parse(line) }
  end

  def test_new_slot_is_created_with_proxy_before_rails_and_only_slot_settings_are_written
    _out, err, status = run_script('deploy_review.sh')
    assert status.success?, err
    create = commands.find { |command| command['args'].first(4) == %w[webapp deployment slot create] }
    assert_includes create['args'], 'ghcr.io/example/app:review-proxy-abc123'
    settings = commands.find { |command| command['args'].first(4) == %w[webapp config appsettings set] }
    assert_includes settings['args'], '--slot'
    assert_equal 'postgresql://review%40user:fake%2Fpassword%3F%23@development-psqlfs.postgres.database.azure.com/pr-123?sslmode=require',
                 settings['body']['DATABASE_URL']
    assert_equal 'review-app-pr-123.azurewebsites.net', settings['body']['DOMAIN']
    assert_equal 'true', settings['body']['REVIEW_APP']
    assert_equal 'production', settings['body']['RAILS_ENV']
    containers = commands.select { |command| command['args'].first == 'rest' }
    assert_equal 3, containers.length
    properties = containers.map { |command| command['body']['properties'] }
    assert_equal([false, false, true], properties.map { |props| props['isMain'] })
    assert_equal(%w[3000 4000 8080], properties.map { |props| props['targetPort'] })
    assert_equal 'ghcr.io/example/app:abc123', properties.first['image']
    simulator = properties[1]['environmentVariables'].to_h { |var| [var['name'], var['value']] }
    assert_equal 'https://review-app-pr-123.azurewebsites.net', simulator['SIMULATOR_URL']
    assert_equal "#{simulator['SIMULATOR_URL']}/users/auth/openid_connect/callback", simulator['REDIRECT_URLS']
    assert_equal 'true', simulator['INTERACTIVE_MODE']
    assert_equal OpenSSL::PKey::RSA.new(settings['body']['GOV_ONE_PRIVATE_KEY']).public_key.to_pem.chomp,
                 simulator['PUBLIC_KEY']
  end

  def test_existing_slot_is_updated_without_creation
    @env['EXISTING_SLOTS'] = 'review-app/pr-123'
    _out, err, status = run_script('deploy_review.sh')
    assert status.success?, err
    refute(commands.any? { |command| command['args'].first(4) == %w[webapp deployment slot create] })
    assert_equal(3, commands.count { |command| command['args'].first == 'rest' })
  end

  def test_deployment_stops_on_azure_failure
    @env['AZ_FAIL'] = 'webapp config appsettings'
    _out, err, status = run_script('deploy_review.sh')
    refute status.success?
    assert_includes err, 'Azure operation failed'
    refute(commands.any? { |command| command['args'].first == 'rest' })
    refute(commands.any? { |command| command['args'].first(2) == %w[webapp start] })
  end

  def test_scaled_out_plan_is_rejected_before_changing_resources
    @env['PLAN_CAPACITY'] = '2'
    _out, err, status = run_script('deploy_review.sh')
    refute status.success?
    assert_includes err, 'single-instance plan'
    assert_equal 2, commands.length
  end

  def test_cleanup_deletes_only_existing_pr_resources
    @env['EXISTING_SLOTS'] = "review-app/pr-123\nreview-app/pr-456"
    @env['EXISTING_DATABASES'] = "development-db\npr-123"
    _out, err, status = run_script('teardown_review.sh')
    assert status.success?, err
    deletes = commands.select { |command| command['args'].include?('delete') }
    assert_equal 2, deletes.length
    deletes.each { |command| assert_includes command['args'], 'pr-123' }
  end

  def test_cleanup_tolerates_absent_resources
    _out, err, status = run_script('teardown_review.sh')
    assert status.success?, err
    refute(commands.any? { |command| command['args'].include?('delete') })
  end

  def test_cleanup_reports_lookup_failure_instead_of_treating_it_as_absence
    @env['AZ_FAIL'] = 'webapp deployment slot list'
    _out, err, status = run_script('teardown_review.sh')
    refute status.success?
    assert_includes err, 'Azure operation failed'
  end

  def test_invalid_pr_is_rejected_before_azure_calls
    @env['PR_NUMBER'] = 'parent'
    %w[deploy_review.sh teardown_review.sh].each do |script|
      _out, err, status = run_script(script)
      refute status.success?
      assert_includes err, 'Invalid PR_NUMBER'
    end
    refute File.exist?(@env.fetch('AZ_LOG'))
  end

  def test_smoke_check_accepts_only_the_expected_review_issuer
    @env['SMOKE_PAGE'] = '<a href="https://review-app-pr-123.azurewebsites.net/authorize?client_id=review&amp;redirect_uri=callback&amp;response_type=code">Continue to GOV.UK One Login</a>'
    url = 'https://review-app-pr-123.azurewebsites.net'
    _out, err, status = run_script('smoke_sign_in.sh', url, url)
    assert status.success?, err
    _out, err, status = run_script('smoke_sign_in.sh', url, 'https://wrong.azurewebsites.net')
    refute status.success?
    assert_includes err, 'Expected review simulator authorize link not found'
    _out, err, status = run_script('smoke_sign_in.sh', url)
    refute status.success?
    assert_includes err, 'account.gov.uk link not found'
  end

  def test_smoke_check_preserves_real_one_login_checks_by_default
    @env['SMOKE_PAGE'] = '<a href="https://oidc.integration.account.gov.uk/authorize?client_id=integration&amp;redirect_uri=callback&amp;response_type=code">Continue to GOV.UK One Login</a>'
    _out, err, status = run_script('smoke_sign_in.sh', 'https://development.azurewebsites.net')
    assert status.success?, err
  end
end
