require 'spec_helper'
require 'tmpdir'
require_relative '../../lib/telemetry_file_logger'

RSpec.describe TelemetryFileLogger do
  it 'uses a separate bounded file when the process identifier changes' do
    Dir.mktmpdir do |directory|
      allow(Process).to receive_messages(pid: 100, kill: true)
      logger = described_class.new(directory, instance_id: 'app-container')
      logger.info('parent')

      allow(Process).to receive(:pid).and_return(200)
      logger.info('child')
      logger.close

      expect(Dir[File.join(directory, 'application-*.json.log')]).to contain_exactly(
        File.join(directory, 'application-app-container-100.json.log'),
        File.join(directory, 'application-app-container-200.json.log'),
      )
    end
  end

  it 'does not collide with another container using the same process identifier' do
    Dir.mktmpdir do |directory|
      allow(Process).to receive_messages(pid: 100, kill: true)

      first = described_class.new(directory, instance_id: 'app-container')
      second = described_class.new(directory, instance_id: 'worker-container')
      first.close
      second.close

      expect(Dir[File.join(directory, 'application-*.json.log')]).to contain_exactly(
        File.join(directory, 'application-app-container-100.json.log'),
        File.join(directory, 'application-worker-container-100.json.log'),
      )
    end
  end

  it 'removes rotations belonging to dead processes in the same container' do
    Dir.mktmpdir do |directory|
      FileUtils.touch(File.join(directory, 'application-app-container-100.json.log'))
      FileUtils.touch(File.join(directory, 'application-app-container-100.json.log.0'))
      FileUtils.touch(File.join(directory, 'application-worker-container-100.json.log'))
      allow(Process).to receive(:pid).and_return(200)
      allow(Process).to receive(:kill).with(0, 100).and_raise(Errno::ESRCH)

      logger = described_class.new(directory, instance_id: 'app-container')
      logger.close

      expect(Dir[File.join(directory, 'application-app-container-100.json.log*')]).to be_empty
      expect(File).to exist(File.join(directory, 'application-worker-container-100.json.log'))
    end
  end
end
