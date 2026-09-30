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
end
