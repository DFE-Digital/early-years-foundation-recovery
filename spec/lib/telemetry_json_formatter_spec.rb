require 'spec_helper'
require 'opentelemetry/sdk'
require_relative '../../lib/telemetry_json_formatter'

RSpec.describe TelemetryJsonFormatter do
  subject(:formatted_log) { JSON.parse(formatter.call('ERROR', timestamp, nil, message)) }

  let(:formatter) { described_class.new }
  let(:timestamp) { Time.utc(2026, 9, 30, 12, 30, 45, 123_456) }
  let(:message) { 'request failed' }

  around do |example|
    original_values = ENV.values_at('OTEL_SERVICE_NAME', 'OTEL_SERVICE_VERSION', 'ENVIRONMENT')
    ENV['OTEL_SERVICE_NAME'] = 'test-service'
    ENV['OTEL_SERVICE_VERSION'] = 'abc123'
    ENV['ENVIRONMENT'] = 'test'
    example.run
  ensure
    %w[OTEL_SERVICE_NAME OTEL_SERVICE_VERSION ENVIRONMENT].zip(original_values).each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end

  it 'emits structured service metadata' do
    expect(formatted_log).to include(
      'timestamp' => '2026-09-30T12:30:45.123456Z',
      'severity' => 'ERROR',
      'message' => 'request failed',
      'logger' => 'Rails',
      'service.name' => 'test-service',
      'service.version' => 'abc123',
      'deployment.environment.name' => 'test',
    )
  end

  it 'adds valid trace and span identifiers' do
    context = instance_double(OpenTelemetry::Trace::SpanContext, valid?: true, trace_id: 1, span_id: 2)
    span = instance_double(OpenTelemetry::Trace::Span, context: context)
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)

    expect(formatted_log).to include(
      'trace_id' => '00000000000000000000000000000001',
      'span_id' => '0000000000000002',
    )
  end

  it 'redacts common secrets and personal identifiers' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    sensitive_message = 'token=abc email=person@example.com user_id=123 for user 456 ip=192.0.2.1 path=/users?token=abc'

    parsed = JSON.parse(formatter.call('WARN', timestamp, nil, sensitive_message))

    expect(parsed['message']).to eq(
      'token=[FILTERED] email=[FILTERED] user_id=[FILTERED] for user [FILTERED] ip=[FILTERED] path=/users?[FILTERED]',
    )
  end

  it 'redacts credentials in compound field names' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    sensitive_message = 'api_key=one access_token:two client_secret="three" password_digest=four'

    parsed = JSON.parse(formatter.call('WARN', timestamp, nil, sensitive_message))

    expect(parsed['message']).to eq(
      'api_key=[FILTERED] access_token:[FILTERED] client_secret=[FILTERED] password_digest=[FILTERED]',
    )
  end

  it 'redacts credentials in JSON-formatted messages' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    sensitive_message = '{"access_token":"one","nested":{"api_key":"two"}}'

    parsed = JSON.parse(formatter.call('WARN', timestamp, nil, sensitive_message))

    expect(parsed['message']).to eq(
      '{"access_token":[FILTERED],"nested":{"api_key":[FILTERED]}}',
    )
  end

  it 'redacts a long quoted secret before truncating the message' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    sensitive_message = %(client_secret="#{'secret ' * 2_000}" trailing)

    parsed = JSON.parse(formatter.call('WARN', timestamp, nil, sensitive_message))

    expect(parsed['message']).to eq('client_secret=[FILTERED] trailing')
  end

  it 'limits message size' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    oversized_message = 'a' * (described_class::MAX_MESSAGE_BYTES + 1)

    parsed = JSON.parse(formatter.call('INFO', timestamp, nil, oversized_message))

    expect(parsed['message'].bytesize).to eq(described_class::MAX_MESSAGE_BYTES)
  end

  it 'preserves valid UTF-8 when truncation splits a multibyte character' do
    allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
    message = "#{'a' * (described_class::MAX_MESSAGE_BYTES - 1)}£"

    parsed = JSON.parse(formatter.call('INFO', timestamp, nil, message))

    expect(parsed['message']).to be_valid_encoding
    expect(parsed['message']).to eq('a' * (described_class::MAX_MESSAGE_BYTES - 1))
  end
end
