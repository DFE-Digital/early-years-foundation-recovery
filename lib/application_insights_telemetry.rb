require_relative 'telemetry_sanitizer'

module ApplicationInsightsTelemetry
  # Helper module for adding custom telemetry to OpenTelemetry spans
  # Add custom attributes to the current span
  #
  # @param attributes [Hash] Attributes to add (no PII!)
  # @example
  #   ApplicationInsightsTelemetry.add_attributes(
  #     'user.role' => 'admin',
  #     'feature.enabled' => 'new_dashboard'
  #   )
  def self.add_attributes(attributes = {})
    return unless enabled?

    current_span = OpenTelemetry::Trace.current_span
    return unless current_span&.recording?

    attributes.each do |key, value|
      current_span.set_attribute(key.to_s, value.to_s)
    end
  end

  # Add an event to the current span
  #
  # @param name [String] Event name
  # @param attributes [Hash] Event attributes (no PII!)
  def self.add_event(name, attributes = {})
    return unless enabled?

    current_span = OpenTelemetry::Trace.current_span
    return unless current_span&.recording?

    current_span.add_event(name, attributes: attributes)
  end

  # Record an exception in the current span
  #
  # @param exception [Exception] The exception to record
  # @param attributes [Hash] Additional attributes
  def self.record_exception(exception, attributes = {})
    return unless enabled?

    current_span = OpenTelemetry::Trace.current_span
    return unless current_span&.recording?

    record_exception_on_span(current_span, exception, attributes)
    current_span.status = OpenTelemetry::Trace::Status.error("Exception: #{exception.class}")
  end

  # Check if OpenTelemetry is enabled
  def self.enabled?
    return false unless defined?(OpenTelemetry)

    ENV.values_at(
      'OTEL_EXPORTER_OTLP_ENDPOINT',
      'SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT',
    ).any? { |endpoint| endpoint.to_s.strip.length.positive? }
  end

  # Create a custom span for a block of code
  #
  # @param name [String] Span name (generic, not user-specific)
  # @param attributes [Hash] Span attributes (no PII!)
  def self.with_span(name, attributes = {}, kind: nil, **keyword_attributes)
    return yield unless enabled?

    tracer = OpenTelemetry.tracer_provider.tracer('early-years-foundation-recovery')
    attributes = attributes.merge(keyword_attributes)
    sanitized_attributes = attributes.transform_values(&:to_s).transform_keys(&:to_s)
    options = {
      attributes: sanitized_attributes,
      record_exception: false,
    }
    options[:kind] = kind if kind
    tracer.in_span(name, **options) do |span|
      yield(span)
    rescue StandardError => e
      record_exception_on_span(span, e)
      span.status = OpenTelemetry::Trace::Status.error("Exception: #{e.class}")
      raise
    end
  end

  def self.record_exception_on_span(span, exception, attributes = {})
    sanitized_attributes = attributes.transform_keys(&:to_s).transform_values do |value|
      TelemetrySanitizer.sanitize(value)
    end
    sanitized_attributes.merge!(
      'exception.type' => exception.class.name,
      'exception.message' => TelemetrySanitizer.sanitize(exception.message),
      'exception.stacktrace' => TelemetrySanitizer.sanitize(Array(exception.backtrace).join("\n")),
    )

    span.add_event('exception', attributes: sanitized_attributes)
  end
  private_class_method :record_exception_on_span
end
