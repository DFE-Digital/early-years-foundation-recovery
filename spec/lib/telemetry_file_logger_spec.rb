require 'spec_helper'
require 'tmpdir'
require_relative '../../lib/telemetry_file_logger'

RSpec.describe TelemetryFileLogger do
  it 'uses a separate bounded file when the process identifier changes' do
    Dir.mktmpdir do |directory|
      allow(Process).to receive(:pid).and_return(100)
      logger = described_class.new(directory)
      logger.info('parent')

      allow(Process).to receive(:pid).and_return(200)
      logger.info('child')
      logger.close

      expect(Dir[File.join(directory, 'application-*.json.log')]).to contain_exactly(
        File.join(directory, 'application-100.json.log'),
        File.join(directory, 'application-200.json.log'),
      )
    end
  end
end
