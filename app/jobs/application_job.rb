class ApplicationJob < Que::Job
  class DuplicateJobError < StandardError
  end

  # Prevent duplicates
  #
  # @return [void]
  def run(*)
    start_time = Time.zone.now
    log 'running'

    if duplicate_job_queued?
      log 'already queued'
      raise DuplicateJobError, 'already queued'
    elsif block_given?
      yield
    end

    log "finished in #{(Time.zone.now - start_time).round(2)} seconds"
  end

private

  # @return [Boolean]
  def duplicate_job_queued?
    Que.job_stats.any? { |job| job[:job_class] == self.class.name && job[:count] > 1 }
  end

  # @param error [Error]
  # @return [void]
  def handle_error(error)
    log("failed with '#{error.message}'")
  end

  # @return [String]
  def log(message)
    message = "#{ENV['DOMAIN']} - #{self.class.name} #{message}"
    Sentry.capture_message(message, level: :info) if Rails.env.production?

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    elsif ENV['VERBOSE'].present?
      puts message
    end
  end
end
