require 'rails_helper'

RSpec.describe ContentCheckJob do
  describe '#run' do
    it 'uses the application job telemetry wrapper' do
      allow(Training::Module.cache).to receive(:clear)
      allow(described_class).to receive(:new).and_call_original
      allow(Training::Module).to receive(:ordered).and_return([])

      expect(ApplicationInsightsTelemetry).to receive(:with_span).with(
        'que.process ContentCheckJob',
        {
          'messaging.system' => 'que',
          'messaging.operation.type' => 'process',
          'code.function.name' => 'ContentCheckJob',
        },
        kind: :consumer,
      ).and_yield

      described_class.run
    end
  end
end
