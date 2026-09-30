# frozen_string_literal: true

require 'json'
require 'logger'
require_relative 'telemetry_sanitizer'

class TelemetryJsonFormatter < Logger::Formatter
  MAX_MESSAGE_BYTES = TelemetrySanitizer::MAX_MESSAGE_BYTES

  def call(severity, timestamp, progname, message)
    payload = {
      timestamp: timestamp.utc.iso8601(6),
      severity: severity,
      message: TelemetrySanitizer.sanitize(msg2str(message)),
      logger: progname || 'Rails',
      'service.name': ENV.fetch('OTEL_SERVICE_NAME', 'early-years-foundation-recovery'),
      'service.version': ENV['OTEL_SERVICE_VERSION'],
      'deployment.environment.name': ENV['ENVIRONMENT'],
    }.compact

    add_trace_context(payload)
    JSON.generate(payload) << "\n"
  end

private

  def add_trace_context(payload)
    return unless defined?(OpenTelemetry::Trace)

    context = OpenTelemetry::Trace.current_span&.context
    return unless context&.valid?

    payload[:trace_id] = sprintf('%032x', context.trace_id)
    payload[:span_id] = sprintf('%016x', context.span_id)
  end
end
