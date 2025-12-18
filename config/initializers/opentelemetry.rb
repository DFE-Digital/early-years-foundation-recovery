# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

# Configure OpenTelemetry for distributed tracing
module OpenTelemetryConfiguration
  class << self
    def configure!
      return unless enabled?

      configure_tracing
    end

  private

    def enabled?
      defined?(OpenTelemetry)
    end

    def service_name
      ENV.fetch('OTEL_SERVICE_NAME', 'rails-app-dev')
    end

    def configure_tracing
      OpenTelemetry::SDK.configure do |c|
        c.service_name = service_name

        # Only export if not in test environment, or if specifically requested (e.g. for integration tests)
        if !Rails.env.test? || ENV['OTEL_EXPORTER_OTLP_ENDPOINT'].present?
          c.add_span_processor(
            OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
              OpenTelemetry::Exporter::OTLP::Exporter.new,
            ),
          )
        end

        # Enable stable instrumentations
        c.use 'OpenTelemetry::Instrumentation::Rails'
        c.use 'OpenTelemetry::Instrumentation::ActiveRecord'
        c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
        c.use 'OpenTelemetry::Instrumentation::Rack'
      end
    end
  end
end

OpenTelemetryConfiguration.configure!
