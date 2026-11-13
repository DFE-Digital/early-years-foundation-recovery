ENV['RAILS_ENV'] ||= 'test'

require_relative '../../config/application'
require 'active_support/all'

RSpec.describe 'Production cache configuration' do
  let(:redis_url) { 'rediss://:password@cache.example.com:10000/0' }
  let(:application) { instance_double(EarlyYearsFoundationRecovery::Application, preview?: false) }
  let(:configuration) do
    ActiveSupport::OrderedOptions.new.tap do |options|
      %i[action_controller action_dispatch public_file_server assets active_storage action_mailer i18n active_support active_record].each do |section|
        options[section] = ActiveSupport::OrderedOptions.new
      end
    end
  end
  let(:configuration_context) { instance_double(Rails::Application, config: configuration) }

  before do
    allow(Rails).to receive(:application).and_return(application)
    allow(application).to receive(:configure) { |&block| configuration_context.instance_eval(&block) }
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ENVIRONMENT').and_return('production')
    allow(ENV).to receive(:[]).with('RAILS_LOG_TO_STDOUT').and_return(nil)
    allow(ENV).to receive(:[]).with('REDIS_URL').and_return(redis_url)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('REDIS_URL').and_return(redis_url)
    allow(ENV).to receive(:fetch).with('CACHE_NAMESPACE', anything).and_return('cache-test:live')

    load File.expand_path('../../config/environments/production.rb', __dir__)
  end

  it 'uses the Redis cache store with TLS and an isolated namespace' do
    expect(configuration.cache_store).to eq([
      :redis_cache_store,
      {
        url: redis_url,
        namespace: 'cache-test:live',
        expires_in: 1.hour,
        connect_timeout: 1,
        read_timeout: 1,
        write_timeout: 1,
        reconnect_attempts: 1,
      },
    ])
  end

  context 'without a Redis URL' do
    let(:redis_url) { nil }

    it 'leaves the default cache store unchanged for development deployments and builds' do
      expect(configuration.cache_store).to be_nil
    end
  end

  context 'with an empty Redis URL' do
    let(:redis_url) { '' }

    it 'leaves the default cache store unchanged' do
      expect(configuration.cache_store).to be_nil
    end
  end

  context 'when Redis is unavailable' do
    let(:redis_url) { 'redis://127.0.0.1:1/0' }
    let(:cache) { ActiveSupport::Cache.lookup_store(*configuration.cache_store) }

    it 'treats reads as cache misses' do
      expect(cache.read('missing')).to be_nil
    end

    it 'still computes values on a cache miss' do
      expect(cache.fetch('missing') { 'computed' }).to eq('computed')
    end

    it 'does not raise when writing' do
      expect { cache.write('missing', 'value') }.not_to raise_error
    end
  end
end
