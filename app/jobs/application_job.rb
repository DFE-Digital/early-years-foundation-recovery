class ApplicationJob < Que::Job
  class DuplicateJobError < StandardError
  end

  # We are checking for duplicate jobs to prevent undesirable mulitple actions in the event of blocked or slow jobs
  #
  # @return [void]
  def run(*)
    start_time = Time.zone.now
    log "#{self.class.name} running"

    if duplicate_job_queued?
      raise DuplicateJobError, "#{self.class.name} already queued"
    elsif block_given?
      yield
    end

    log "#{self.class.name} finished in #{(Time.zone.now - start_time).round(2)} seconds"
  end

private

  # @return [Boolean]
  def duplicate_job_queued?
    Que.job_stats.any? { |job| job[:job_class] == self.class.name && job[:count] > 1 }
  end

  # @param error [Error]
  # @return [void]
  def handle_error(error)
    log("#{self.class.name} failed with '#{error.message}'")
  end

  # @return [String]
  def log(message)
    Sentry.capture_message(message, level: :info) if Rails.application.live?

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    elsif ENV['VERBOSE'].present?
      puts message
    end
  end
end
