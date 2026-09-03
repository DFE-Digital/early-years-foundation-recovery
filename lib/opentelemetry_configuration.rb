# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

module OpenTelemetryConfiguration
  class << self
    def configure!
      return unless enabled?

      configure_tracing
    end

    def trace_exporter_configs
      configs = []

      if (endpoint = ENV['OTEL_EXPORTER_OTLP_ENDPOINT'].to_s.strip).length.positive?
        configs << { endpoint: endpoint, headers: headers_from_env('OTEL_EXPORTER_OTLP_HEADERS') }
      end

      if (splunk_endpoint = ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'].to_s.strip).length.positive?
        configs << {
          endpoint: splunk_endpoint,
          headers: headers_from_env('SPLUNK_OTEL_EXPORTER_OTLP_HEADERS'),
        }
      end

      configs
    end

    private

    def enabled?
      defined?(OpenTelemetry)
    end

    def service_name
      ENV.fetch('OTEL_SERVICE_NAME', 'rails-app-dev')
    end

    def configure_tracing
      exporter_configs = trace_exporter_configs
      return if exporter_configs.empty?

      OpenTelemetry::SDK.configure do |c|
        c.service_name = service_name

        exporter_configs.each do |config|
          c.add_span_processor(
            OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
              OpenTelemetry::Exporter::OTLP::Exporter.new(
                endpoint: config[:endpoint],
                headers: config[:headers],
              ),
            ),
          )
        end

        c.use 'OpenTelemetry::Instrumentation::Rails'
        c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
        c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
        c.use 'OpenTelemetry::Instrumentation::Rack', untraced_endpoints: ['/health']
      end
    end

    def headers_from_env(env_key)
      value = ENV[env_key].to_s.strip
      return {} if value.empty?

      value.split(',').each_with_object({}) do |pair, headers|
        key, separator, header_value = pair.partition('=')
        next if key.strip.empty? || separator.empty?

        headers[key.strip] = header_value.strip
      end
    end
  end
end
