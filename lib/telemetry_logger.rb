# frozen_string_literal: true

require 'active_support/logger'
require 'active_support/isolated_execution_state'
require_relative 'opentelemetry_configuration'
require_relative 'telemetry_sanitizer'

class TelemetryLogger < ActiveSupport::Logger
  SEVERITY_NUMBERS = {
    DEBUG => 5,
    INFO => 9,
    WARN => 13,
    ERROR => 17,
    FATAL => 21,
    UNKNOWN => 0,
  }.freeze

  def initialize
    super(nil)
  end

  def add(severity, message = nil, progname = nil)
    severity ||= UNKNOWN
    return true if severity < level

    message = block_given? ? yield : progname if message.nil?
    timestamp = Time.now # rubocop:disable Rails/TimeZone
    body = formatter.call(Logger::SEV_LABEL[severity] || 'ANY', timestamp, progname, message)
    OpenTelemetryConfiguration.logger&.on_emit(
      timestamp: timestamp,
      severity_number: SEVERITY_NUMBERS.fetch(severity, 0),
      severity_text: Logger::SEV_LABEL[severity] || 'ANY',
      body: TelemetrySanitizer.sanitize(body),
    )
    true
  end
end
