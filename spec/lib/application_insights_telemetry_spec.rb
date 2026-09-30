require 'spec_helper'
require 'opentelemetry/sdk'
require_relative '../../lib/application_insights_telemetry'

RSpec.describe ApplicationInsightsTelemetry do
  describe '.add_attributes' do
    context 'when OpenTelemetry is disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      it 'does not attempt to add attributes' do
        expect(OpenTelemetry::Trace).not_to receive(:current_span)
        described_class.add_attributes('key' => 'value')
      end
    end

    context 'when OpenTelemetry is enabled' do
      let(:span) { instance_double(OpenTelemetry::Trace::Span, recording?: true) }

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
      end

      it 'adds attributes to the current span' do
        expect(span).to receive(:set_attribute).with('user.role', 'admin')
        expect(span).to receive(:set_attribute).with('feature.enabled', 'true')

        described_class.add_attributes(
          'user.role' => 'admin',
          'feature.enabled' => true,
        )
      end

      context 'when span is not recording' do
        let(:span) { instance_double(OpenTelemetry::Trace::Span, recording?: false) }

        it 'does not add attributes' do
          expect(span).not_to receive(:set_attribute)
          described_class.add_attributes('key' => 'value')
        end
      end

      context 'when there is no current span' do
        before do
          allow(OpenTelemetry::Trace).to receive(:current_span).and_return(nil)
        end

        it 'does not raise an error' do
          expect { described_class.add_attributes('key' => 'value') }.not_to raise_error
        end
      end
    end
  end

  describe '.add_event' do
    context 'when OpenTelemetry is enabled' do
      let(:span) { instance_double(OpenTelemetry::Trace::Span, recording?: true) }

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
      end

      it 'adds an event to the current span' do
        expect(span).to receive(:add_event).with('user_action', attributes: { 'action' => 'click' })

        described_class.add_event('user_action', 'action' => 'click')
      end
    end
  end

  describe '.record_exception' do
    context 'when OpenTelemetry is enabled' do
      let(:span) { instance_double(OpenTelemetry::Trace::Span, recording?: true) }
      let(:exception) do
        StandardError.new('request failed access_token=secret').tap do |error|
          error.set_backtrace(['/app/example.rb?api_key=secret:1'])
        end
      end

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
      end

      it 'records the exception on the current span' do
        expect(span).to receive(:add_event).with(
          'exception',
          attributes: {
            'exception.type' => 'StandardError',
            'exception.message' => 'request failed access_token=[FILTERED]',
            'exception.stacktrace' => '/app/example.rb?[FILTERED]',
          },
        )
        expect(span).to receive(:status=).with(
          have_attributes(code: OpenTelemetry::Trace::Status::ERROR, description: 'Exception: StandardError'),
        )

        described_class.record_exception(exception)
      end

      it 'accepts additional attributes' do
        attrs = { 'context' => 'client_secret=secret' }
        expect(span).to receive(:add_event).with(
          'exception',
          attributes: hash_including('context' => 'client_secret=[FILTERED]'),
        )
        expect(span).to receive(:status=)

        described_class.record_exception(exception, attrs)
      end
    end
  end

  describe '.enabled?' do
    around do |example|
      original_values = ENV.values_at(
        'OTEL_EXPORTER_OTLP_ENDPOINT',
        'SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT',
      )

      example.run
    ensure
      %w[OTEL_EXPORTER_OTLP_ENDPOINT SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT].zip(original_values).each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    context 'when OpenTelemetry is defined and the collector endpoint is present' do
      before do
        stub_const('OpenTelemetry', Module.new)
        ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'http://otel-collector:4318/v1/traces'
      end

      it 'returns true' do
        expect(described_class.enabled?).to be true
      end
    end

    context 'when only the direct Splunk endpoint is present' do
      before do
        stub_const('OpenTelemetry', Module.new)
        ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')
        ENV['SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://ingest.eu2.observability.splunkcloud.com/v2/trace/otlp'
      end

      it 'returns true' do
        expect(described_class.enabled?).to be true
      end
    end

    context 'when OpenTelemetry is not defined' do
      before do
        hide_const('OpenTelemetry')
      end

      it 'returns false' do
        expect(described_class.enabled?).to be false
      end
    end

    context 'when no exporter endpoint is present' do
      before do
        stub_const('OpenTelemetry', Module.new)
        ENV.delete('OTEL_EXPORTER_OTLP_ENDPOINT')
        ENV.delete('SPLUNK_OTEL_EXPORTER_OTLP_ENDPOINT')
      end

      it 'returns false' do
        expect(described_class.enabled?).to be false
      end
    end
  end

  describe '.with_span' do
    context 'when OpenTelemetry is enabled' do
      let(:tracer) { instance_double(OpenTelemetry::Trace::Tracer) }
      let(:tracer_provider) { instance_double(OpenTelemetry::Trace::TracerProvider) }
      let(:span) { instance_double(OpenTelemetry::Trace::Span) }

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry).to receive(:tracer_provider).and_return(tracer_provider)
        allow(tracer_provider).to receive(:tracer).with('early-years-foundation-recovery').and_return(tracer)
      end

      it 'creates a custom span and yields to the block' do
        allow(tracer).to receive(:in_span).and_yield(span)

        result = described_class.with_span('custom_operation', 'count' => 5) do
          'result'
        end

        expect(tracer).to have_received(:in_span).with(
          'custom_operation',
          attributes: { 'count' => '5' },
          record_exception: false,
        )
        expect(result).to eq 'result'
      end

      it 'creates a span with an explicit kind' do
        allow(tracer).to receive(:in_span).and_yield(span)

        described_class.with_span('job operation', { 'messaging.system' => 'que' }, kind: :consumer) { nil }

        expect(tracer).to have_received(:in_span).with(
          'job operation',
          attributes: { 'messaging.system' => 'que' },
          kind: :consumer,
          record_exception: false,
        )
      end

      it 'records exceptions if they occur' do
        error = StandardError.new('test error')
        allow(tracer).to receive(:in_span).and_yield(span)
        expect(span).to receive(:add_event).with(
          'exception',
          attributes: hash_including(
            'exception.type' => 'StandardError',
            'exception.message' => 'test error',
          ),
        )
        expect(span).to receive(:status=).with(
          have_attributes(code: OpenTelemetry::Trace::Status::ERROR, description: 'Exception: StandardError'),
        )

        expect {
          described_class.with_span('failing_operation') { raise error }
        }.to raise_error(StandardError, 'test error')
      end
    end

    context 'when OpenTelemetry is disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      it 'yields to the block without creating a span' do
        expect(OpenTelemetry).not_to receive(:tracer_provider)

        result = described_class.with_span('operation') { 'result' }
        expect(result).to eq 'result'
      end
    end
  end
end
