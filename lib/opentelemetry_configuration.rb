# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry-logs-sdk'
require 'opentelemetry/exporter/otlp_logs'
require 'uri'

module OpenTelemetryConfiguration
  @logging_mutex = Mutex.new
  @logging_process_id = Process.pid

  class << self
    def logger
      @logger if @logger_process_id == Process.pid
    end

    def configure!
      return unless enabled?

      configure_tracing
    end

    def configure_logging!
      return unless enabled?

      reset_logging_state_after_fork
      @logging_mutex.synchronize do
        return @logger if @logger && @logger_process_id == Process.pid

        configure_logging
      end
    end

    def logs_enabled?
      logs_exporter_configs.any?
    end

    def trace_exporter_configs
      configs = []

      if (endpoint = otlp_endpoint).length.positive?
        configs << { endpoint: endpoint, headers: headers_from_env('OTEL_EXPORTER_OTLP_HEADERS') }
      end

      if (splunk_endpoint = ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'].to_s.strip).length.positive? &&
          (headers = splunk_exporter_headers).any? &&
          (endpoint = splunk_endpoint_uri(splunk_endpoint))
        configs << {
          endpoint: endpoint.to_s,
          headers: headers,
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

    def otlp_endpoint
      ENV['OTEL_EXPORTER_OTLP_ENDPOINT'].to_s.strip
    end

    def logs_endpoint
      base_endpoint = otlp_endpoint.sub(%r{/*\z}, '').sub(%r{/v1/(?:traces|logs)\z}, '')
      "#{base_endpoint}/v1/logs"
    end

    def logs_exporter_configs
      configs = []

      if otlp_endpoint.length.positive?
        configs << { endpoint: logs_endpoint, headers: headers_from_env('OTEL_EXPORTER_OTLP_HEADERS') }
      end

      if (splunk_endpoint = ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'].to_s.strip).length.positive? &&
          (headers = splunk_exporter_headers).any? &&
          (endpoint = splunk_endpoint_uri(splunk_endpoint))
        endpoint.path = '/v1/log'
        configs << {
          endpoint: endpoint.to_s,
          headers: headers,
        }
      end

      configs
    end

    def splunk_endpoint_uri(endpoint)
      uri = URI.parse(endpoint)
      return unless uri.is_a?(URI::HTTPS) && uri.host

      uri
    rescue URI::InvalidURIError
      nil
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

    def configure_logging
      exporter_configs = logs_exporter_configs
      return if exporter_configs.empty?

      resource = OpenTelemetry::SDK::Resources::Resource.create('service.name' => service_name) # rubocop:disable Rails/SaveBang
      provider = OpenTelemetry::SDK::Logs::LoggerProvider.new(resource: resource)
      exporter_configs.each do |config|
        exporter = OpenTelemetry::Exporter::OTLP::Logs::LogsExporter.new(
          endpoint: config[:endpoint],
          headers: config[:headers],
        )
        provider.add_log_record_processor(
          OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter),
        )
      end

      @logger = provider.logger(name: 'rails')
      provider_process_id = Process.pid
      @logger_process_id = provider_process_id
      at_exit { provider.shutdown if Process.pid == provider_process_id }
    end

    def reset_logging_state_after_fork
      return if @logging_process_id == Process.pid

      @logging_mutex = Mutex.new
      @logging_process_id = Process.pid
      @logger = nil
      @logger_process_id = nil
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

    def splunk_exporter_headers
      headers = headers_from_env('SPLUNK_OTEL_EXPORTER_OTLP_HEADERS')
      return {} unless headers.any? do |key, value|
        key.casecmp('X-SF-Token').zero? && value.to_s.strip.length.positive?
      end

      headers
    end
  end
end
