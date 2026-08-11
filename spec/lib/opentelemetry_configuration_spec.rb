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

    it 'adds a Splunk exporter when Splunk OTLP settings are present' do
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318/v1/traces'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.us0.signalfx.com/v2/trace'
      ENV['SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'] = 'X-SF-Token=abc123'

      expect(described_class.trace_exporter_configs).to include(
        { endpoint: 'http://otel-collector:4318/v1/traces', headers: {} },
        { endpoint: 'https://ingest.us0.signalfx.com/v2/trace', headers: { 'X-SF-Token' => 'abc123' } },
      )
    end
  end
end
