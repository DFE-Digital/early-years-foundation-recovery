# frozen_string_literal: true

require 'active_support/logger'
require 'active_support/isolated_execution_state'
require 'fileutils'
require 'socket'

class TelemetryFileLogger < ActiveSupport::Logger
  SHIFT_AGE = 5
  SHIFT_SIZE = 10 * 1024 * 1024

  def initialize(directory, instance_id: ENV['HOSTNAME'].to_s.empty? ? Socket.gethostname : ENV['HOSTNAME'])
    @directory = directory
    @instance_id = instance_id.gsub(/[^a-zA-Z0-9_.-]/, '_')
    FileUtils.mkdir_p(directory)
    @telemetry_pid = Process.pid
    remove_stale_process_logs
    super(log_path(@telemetry_pid), SHIFT_AGE, SHIFT_SIZE)
  end

  def add(...)
    reopen_for_current_process
    super
  end

private

  def reopen_for_current_process
    current_pid = Process.pid
    return if @telemetry_pid == current_pid

    remove_stale_process_logs
    reopen(log_path(current_pid), SHIFT_AGE, SHIFT_SIZE)
    @telemetry_pid = current_pid
  end

  def log_path(pid)
    File.join(@directory, "application-#{@instance_id}-#{pid}.json.log")
  end

  def remove_stale_process_logs
    Dir[File.join(@directory, "application-#{@instance_id}-*.json.log*")]
      .group_by { |path| process_id(path) }
      .each do |pid, paths|
        paths.each { |path| FileUtils.rm_f(path) } unless process_alive?(pid)
      end
  end

  def process_id(path)
    File.basename(path).match(/-(\d+)\.json\.log(?:\.\d+)?\z/)&.captures&.first&.to_i
  end

  def process_alive?(pid)
    return false unless pid

    Process.kill(0, pid)
    true
  rescue Errno::ESRCH
    false
  rescue Errno::EPERM
    true
  end
end
