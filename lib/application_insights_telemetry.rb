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

    current_span.record_exception(exception, attributes: attributes)
    current_span.status = OpenTelemetry::Trace::Status.error("Exception: #{exception.class}")
  end

  # Check if OpenTelemetry is enabled
  def self.enabled?
    defined?(OpenTelemetry) && ENV['APPLICATION_INSIGHTS_CONNECTION_STRING'].present?
  end

  # Create a custom span for a block of code
  #
  # @param name [String] Span name (generic, not user-specific)
  # @param attributes [Hash] Span attributes (no PII!)
  def self.with_span(name, attributes = {}, &block)
    return yield unless enabled?

    tracer = OpenTelemetry.tracer_provider.tracer('early-years-foundation-recovery')
    tracer.in_span(name, attributes: attributes, &block)
  rescue StandardError => e
    record_exception(e)
    raise
  end
end
