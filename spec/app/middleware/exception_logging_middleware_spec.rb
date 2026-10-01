require 'rails_helper'

RSpec.describe ExceptionLoggingMiddleware do
  subject(:middleware) { described_class.new(app) }

  let(:error) { StandardError.new('test error') }
  let(:app) { ->(_env) { raise error } }
  let(:request) { Rack::MockRequest.env_for('/broken') }

  before do
    allow(Rails.logger).to receive(:error)
    allow(Rails.error).to receive(:report)
    allow(ApplicationInsightsTelemetry).to receive(:record_exception)
  end

  it 'records an unhandled exception on the current telemetry span' do
    expect(ApplicationInsightsTelemetry).to receive(:record_exception).with(error)

    expect { middleware.call(request) }.to raise_error(error)
  end

  it 'sanitizes exception details before broadcasting the log record' do
    sensitive_error = StandardError.new('failed access_token=secret')
    sensitive_error.set_backtrace(['/app/example.rb?api_key=secret:1'])
    sensitive_app = ->(_env) { raise sensitive_error }
    sensitive_request = Rack::MockRequest.env_for('/broken?api_key=secret')

    expect(Rails.logger).to receive(:error) do |&block|
      message = block.call
      expect(message).to include(
        'access_token=[FILTERED]',
        '?[FILTERED]',
      )
      expect(message).to match(/"api_key"\s*=>\s*\[FILTERED\]/)
      expect(message).not_to include('secret')
    end

    expect { described_class.new(sensitive_app).call(sensitive_request) }.to raise_error(sensitive_error)
  end
end
