require 'spec_helper'
require 'active_support/core_ext/enumerable'
require_relative '../../lib/opentelemetry_configuration'

RSpec.describe OpenTelemetryConfiguration do
  describe '.trace_exporter_configs' do
    around do |example|
      original_values = {
        'OTEL_EXPORTER_OTLP_ENDPOINT' => ENV['OTEL_EXPORTER_OTLP_ENDPOINT'],
        'OTEL_EXPORTER_OTLP_HEADERS' => ENV['OTEL_EXPORTER_OTLP_HEADERS'],
        'SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT' => ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'],
        'SPLUNK_OTEL_EXPORTER_OTLP_HEADERS' => ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'],
      }
      original_values.each_key { |key| ENV.delete(key) }

      example.run
    ensure
      original_values&.each do |key, value|
        if value.nil?
          ENV.delete(key)
        else
          ENV[key] = value
        end
      end
    end

    it 'returns the default collector exporter when only the legacy endpoint is configured' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318/v1/traces'

      expect(described_class.trace_exporter_configs).to eq([
        { endpoint: 'http://otel-collector:4318/v1/traces', headers: {} },
      ])
    end

    it 'adds a Splunk Observability OTLP exporter when Splunk settings are present' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318/v1/traces'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.trace_exporter_configs).to include(
        { endpoint: 'http://otel-collector:4318/v1/traces', headers: {} },
        { endpoint: 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp', headers: { 'X-SF-Token' => 'test-token' } },
      )
    end

    it 'does not configure direct Splunk tracing without its auth token' do
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'

      expect(described_class.trace_exporter_configs).to eq([])
    end

    it 'ignores an invalid direct Splunk tracing endpoint' do
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://bad host/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.trace_exporter_configs).to eq([])
    end
  end

  describe '.logs_enabled?' do
    around do |example|
      original_values = {}
      original_values.merge!(%w[
        OTEL_EXPORTER_OTLP_ENDPOINT
        SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT
        SPLUNK_OTEL_EXPORTER_OTLP_HEADERS
      ].index_with { |key| ENV[key] })
      original_values.each_key { |key| ENV.delete(key) }
      example.run
    ensure
      original_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    it 'is enabled when the local collector endpoint is configured' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://localhost:4318/v1/traces'

      expect(described_class.logs_enabled?).to be(true)
    end

    it 'is disabled without a local collector endpoint' do
      ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')

      expect(described_class.logs_enabled?).to be(false)
    end

    it 'is enabled with a direct Splunk endpoint' do
      ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.logs_enabled?).to be(true)
    end

    it 'is disabled for a Splunk endpoint without its auth token' do
      ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV.delete('SPLUNK_OTEL_EXPORTER_OTLP_HEADERS')

      expect(described_class.logs_enabled?).to be(false)
    end

    it 'is disabled for an invalid direct Splunk endpoint' do
      ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://bad host/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.logs_enabled?).to be(false)
    end
  end

  describe '.logs_exporter_configs' do
    around do |example|
      original_values = {
        'OTEL_EXPORTER_OTLP_ENDPOINT' => ENV['OTEL_EXPORTER_OTLP_ENDPOINT'],
        'OTEL_EXPORTER_OTLP_HEADERS' => ENV['OTEL_EXPORTER_OTLP_HEADERS'],
        'SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT' => ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'],
        'SPLUNK_OTEL_EXPORTER_OTLP_HEADERS' => ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'],
      }
      original_values.each_key { |key| ENV.delete(key) }

      example.run
    ensure
      original_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    it 'does not configure Splunk log export without an auth token' do
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token='

      expect(described_class.send(:logs_exporter_configs)).to eq([])
    end

    it 'does not configure Splunk log export with an invalid endpoint' do
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://bad host/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.send(:logs_exporter_configs)).to eq([])
    end

    it 'configures a Splunk logs endpoint with Splunk authentication headers' do
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=test-token'

      expect(described_class.send(:logs_exporter_configs)).to eq([
        {
          endpoint: 'https://ingest.eu2.observability.splunkcloud.com/v1/log',
          headers: { 'X-SF-Token' => 'test-token' },
        },
      ])
    end
  end

  describe '.configure_logging!' do
    around do |example|
      original_values = {}
      original_environment = {}
      instance_variables = %i[@logger @logger_process_id @logging_process_id @logging_mutex]
      original_values.merge!(instance_variables.index_with do |name|
        described_class.instance_variable_get(name)
      end)
      environment_keys = %w[
        OTEL_EXPORTER_OTLP_ENDPOINT
        OTEL_EXPORTER_OTLP_HEADERS
        SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT
        SPLUNK_OTEL_EXPORTER_OTLP_HEADERS
        OTEL_SERVICE_NAME
      ]
      original_environment.merge!(environment_keys.index_with { |key| ENV[key] })
      environment_keys.each { |key| ENV.delete(key) }
      example.run
    ensure
      original_values.each do |name, value|
        described_class.instance_variable_set(name, value)
      end
      original_environment.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    it 'initializes the logger once when called concurrently' do
      telemetry_logger = Object.new
      calls = 0
      calls_mutex = Mutex.new
      allow(described_class).to receive(:enabled?).and_return(true)
      allow(described_class).to receive(:configure_logging) do
        calls_mutex.synchronize do
          calls += 1
          described_class.instance_variable_set(:@logger, telemetry_logger)
          described_class.instance_variable_set(:@logger_process_id, Process.pid)
        end
      end

      threads = Array.new(8) { Thread.new { described_class.configure_logging! } }
      threads.each(&:value)

      expect(calls).to eq(1)
      expect(described_class.logger).to equal(telemetry_logger)
    end

    it 'reinitializes a logger inherited across a fork' do
      inherited_logger = Object.new
      worker_logger = Object.new
      parent_process_id = Process.pid - 1
      described_class.instance_variable_set(:@logging_process_id, parent_process_id)
      described_class.instance_variable_set(:@logger_process_id, parent_process_id)
      described_class.instance_variable_set(:@logger, inherited_logger)
      allow(described_class).to receive(:enabled?).and_return(true)
      allow(described_class).to receive(:configure_logging) do
        described_class.instance_variable_set(:@logger, worker_logger)
        described_class.instance_variable_set(:@logger_process_id, Process.pid)
      end

      described_class.configure_logging!

      expect(described_class.logger).to equal(worker_logger)
    end

    it 'constructs exporters, processors, logger, and shutdown callback from configured endpoints' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318/v1/traces'
      ENV['OTEL_EXPORTER_OTLP_HEADERS'] = 'X-Collector-Token=collector-token'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=splunk-token'
      ENV['OTEL_SERVICE_NAME'] = 'test-service'
      described_class.instance_variable_set(:@logging_process_id, Process.pid)
      described_class.instance_variable_set(:@logger, nil)
      described_class.instance_variable_set(:@logger_process_id, nil)

      resource = instance_double(OpenTelemetry::SDK::Resources::Resource)
      provider = instance_double(OpenTelemetry::SDK::Logs::LoggerProvider)
      allow(provider).to receive(:shutdown)
      collector_exporter = instance_double(OpenTelemetry::Exporter::OTLP::Logs::LogsExporter)
      splunk_exporter = instance_double(OpenTelemetry::Exporter::OTLP::Logs::LogsExporter)
      collector_processor = instance_double(OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor)
      splunk_processor = instance_double(OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor)
      telemetry_logger = instance_double(OpenTelemetry::SDK::Logs::Logger)
      shutdown_callback = nil

      allow(OpenTelemetry::SDK::Resources::Resource).to receive(:create)
        .with('service.name' => 'test-service').and_return(resource)
      allow(OpenTelemetry::SDK::Logs::LoggerProvider).to receive(:new)
        .with(resource: resource).and_return(provider)
      expect(OpenTelemetry::Exporter::OTLP::Logs::LogsExporter).to receive(:new)
        .with(endpoint: 'http://otel-collector:4318/v1/logs', headers: { 'X-Collector-Token' => 'collector-token' })
        .ordered.and_return(collector_exporter)
      expect(OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor).to receive(:new)
        .with(collector_exporter).ordered.and_return(collector_processor)
      expect(OpenTelemetry::Exporter::OTLP::Logs::LogsExporter).to receive(:new)
        .with(endpoint: 'https://ingest.eu2.observability.splunkcloud.com/v1/log', headers: { 'X-SF-Token' => 'splunk-token' })
        .ordered.and_return(splunk_exporter)
      expect(OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor).to receive(:new)
        .with(splunk_exporter).ordered.and_return(splunk_processor)
      expect(provider).to receive(:add_log_record_processor).with(collector_processor)
      expect(provider).to receive(:add_log_record_processor).with(splunk_processor)
      allow(provider).to receive(:logger).with(name: 'rails').and_return(telemetry_logger)
      allow(described_class).to receive(:at_exit) { |&block| shutdown_callback = block }

      described_class.configure_logging!

      expect(OpenTelemetry::SDK::Resources::Resource).to have_received(:create)
        .with('service.name' => 'test-service')
      expect(OpenTelemetry::SDK::Logs::LoggerProvider).to have_received(:new).with(resource: resource)
      expect(provider).to have_received(:logger).with(name: 'rails')
      expect(described_class.logger).to equal(telemetry_logger)
      expect(shutdown_callback).to be_a(Proc)
      shutdown_callback.call
      expect(provider).to have_received(:shutdown)
    end
  end

  describe 'logs endpoint configuration' do
    around do |example|
      original_endpoint = ENV['OTEL_EXPORTER_OTLP_ENDPOINT']
      example.run
    ensure
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = original_endpoint
    end

    it 'adds the logs path to a base collector endpoint' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318'

      expect(described_class.send(:logs_endpoint)).to eq('http://otel-collector:4318/v1/logs')
    end

    it 'replaces the traces path and tolerates a trailing slash' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://localhost:4318/v1/traces/'

      expect(described_class.send(:logs_endpoint)).to eq('http://localhost:4318/v1/logs')
    end
  end
end
