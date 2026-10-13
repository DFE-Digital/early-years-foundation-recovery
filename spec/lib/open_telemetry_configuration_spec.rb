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
  end

  describe '.logs_enabled?' do
    around do |example|
      original_values = %w[OTEL_EXPORTER_OTLP_ENDPOINT SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT].index_with { |key| ENV[key] }
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

      expect(described_class.logs_enabled?).to be(true)
    end
  end

  describe '.logs_exporter_configs' do
    around do |example|
      original_values = %w[
        OTEL_EXPORTER_OTLP_ENDPOINT
        OTEL_EXPORTER_OTLP_HEADERS
        SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT
        SPLUNK_OTEL_EXPORTER_OTLP_HEADERS
      ].index_with { |key| ENV[key] }
      original_values.each_key { |key| ENV.delete(key) }

      example.run
    ensure
      original_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
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
      instance_variables = %i[@logger @logger_process_id @logging_process_id @logging_mutex]
      original_values = instance_variables.index_with do |name|
        described_class.instance_variable_get(name)
      end
      example.run
    ensure
      original_values.each do |name, value|
        described_class.instance_variable_set(name, value)
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
