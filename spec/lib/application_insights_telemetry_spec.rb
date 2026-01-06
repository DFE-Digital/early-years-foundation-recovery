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
      let(:exception) { StandardError.new('test error') }

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry::Trace).to receive(:current_span).and_return(span)
      end

      it 'records the exception on the current span' do
        expect(span).to receive(:record_exception).with(exception, attributes: {})
        expect(span).to receive(:status=)

        described_class.record_exception(exception)
      end

      it 'accepts additional attributes' do
        attrs = { 'context' => 'test' }
        expect(span).to receive(:record_exception).with(exception, attributes: attrs)
        expect(span).to receive(:status=)

        described_class.record_exception(exception, attrs)
      end
    end
  end

  describe '.enabled?' do
    context 'when OpenTelemetry is defined and connection string is present' do
      before do
        stub_const('OpenTelemetry', Module.new)
        allow(ENV).to receive(:[]).with('APPLICATION_INSIGHTS_CONNECTION_STRING').and_return('test-connection-string')
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

    context 'when connection string is not present' do
      before do
        stub_const('OpenTelemetry', Module.new)
        allow(ENV).to receive(:[]).with('APPLICATION_INSIGHTS_CONNECTION_STRING').and_return(nil)
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

      before do
        allow(described_class).to receive(:enabled?).and_return(true)
        allow(OpenTelemetry).to receive(:tracer_provider).and_return(tracer_provider)
        allow(tracer_provider).to receive(:tracer).with('early-years-foundation-recovery').and_return(tracer)
      end

      it 'creates a custom span and yields to the block' do
        expect(tracer).to receive(:in_span).with('custom_operation', attributes: { 'count' => '5' }).and_yield

        result = described_class.with_span('custom_operation', 'count' => 5) do
          'result'
        end

        expect(result).to eq 'result'
      end

      it 'records exceptions if they occur' do
        error = StandardError.new('test error')
        allow(tracer).to receive(:in_span).and_raise(error)
        expect(described_class).to receive(:record_exception).with(error)

        expect {
          described_class.with_span('failing_operation') { 'code' }
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
