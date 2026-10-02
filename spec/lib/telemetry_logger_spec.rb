# frozen_string_literal: true

require_relative '../../lib/telemetry_logger'

RSpec.describe TelemetryLogger do
  subject(:logger) { described_class.new }

  let(:otel_logger) { instance_double(OpenTelemetry::SDK::Logs::Logger, on_emit: nil) }

  before do
    allow(OpenTelemetryConfiguration).to receive(:logger).and_return(otel_logger)
  end

  it 'exports a sanitized log with its severity' do
    logger.error('login failed for user@example.com with access_token=secret')

    expect(otel_logger).to have_received(:on_emit).with(
      hash_including(
        severity_number: 17,
        severity_text: 'ERROR',
        body: "login failed for [FILTERED] with access_token=[FILTERED]\n",
      ),
    )
  end

  it 'does not export logs below its configured level' do
    logger.level = Logger::WARN
    logger.info('ignored')

    expect(otel_logger).not_to have_received(:on_emit)
  end

  it 'accepts invalid UTF-8 without breaking application logging' do
    expect { logger.info("message \xC3".b) }.not_to raise_error
  end
end
