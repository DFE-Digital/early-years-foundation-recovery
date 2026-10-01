# frozen_string_literal: true

require 'active_support/logger'
require 'fileutils'

class TelemetryFileLogger < ActiveSupport::Logger
  SHIFT_AGE = 5
  SHIFT_SIZE = 10 * 1024 * 1024

  def initialize(directory)
    @directory = directory
    FileUtils.mkdir_p(directory)
    @telemetry_pid = Process.pid
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

    reopen(log_path(current_pid), SHIFT_AGE, SHIFT_SIZE)
    @telemetry_pid = current_pid
  end

  def log_path(pid)
    File.join(@directory, "application-#{pid}.json.log")
  end
end
