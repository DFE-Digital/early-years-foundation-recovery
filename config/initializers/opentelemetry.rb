# frozen_string_literal: true

require_relative '../../lib/opentelemetry_configuration'

# Initialize OpenTelemetry at boot
OpenTelemetryConfiguration.configure!
