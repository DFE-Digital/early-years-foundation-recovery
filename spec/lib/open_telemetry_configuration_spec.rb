require 'spec_helper'
require_relative '../../lib/opentelemetry_configuration'

RSpec.describe OpenTelemetryConfiguration do
  describe '.resource_attributes' do
    around do |example|
      original_values = ENV.values_at('WEBSITE_INSTANCE_ID', 'HOSTNAME')
      example.run
    ensure
      %w[WEBSITE_INSTANCE_ID HOSTNAME].zip(original_values).each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    it 'uses the Azure App Service instance identifier when available' do
      ENV['WEBSITE_INSTANCE_ID'] = 'web-instance'
      ENV['HOSTNAME'] = 'container-hostname'

      expect(described_class.resource_attributes).to eq('service.instance.id' => 'web-instance')
    end

    it 'uses the container hostname outside App Service' do
      ENV.delete('WEBSITE_INSTANCE_ID')
      ENV['HOSTNAME'] = 'worker-instance'

      expect(described_class.resource_attributes).to eq('service.instance.id' => 'worker-instance')
    end
  end

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
end
