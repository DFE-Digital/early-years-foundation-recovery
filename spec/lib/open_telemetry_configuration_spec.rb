require 'spec_helper'
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
      original_values.each do |key, value|
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
      original_endpoint = ENV['OTEL_EXPORTER_OTLP_ENDPOINT']
      example.run
    ensure
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = original_endpoint
    end

    it 'is enabled when the local collector endpoint is configured' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://localhost:4318/v1/traces'

      expect(described_class.logs_enabled?).to be(true)
    end

    it 'is disabled without a local collector endpoint' do
      ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')

      expect(described_class.logs_enabled?).to be(false)
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
