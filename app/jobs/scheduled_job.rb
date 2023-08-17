class ScheduledJob < Que::Job
  def run
    log "#{self.class.name} running"
    if duplicate_job_queued?
      log_duplicate
      return
    end

    super
  end

private

  def duplicate_job_queued?
    Que.job_stats.any? { |job| job[:job_class] == self.class.name && job[:count] > 1 }
  end

  # @return [String]
  def log_duplicate
    message = "Duplicate #{self.class.name} job queued - skipping"
    Sentry.capture_message(message) if Rails.application.live?
    log(message)
  end

  def handle_error(error)
    message = "#{self.class.name} failed with '#{error.message}'"
    log(message)
    Sentry.capture_message(message) if Rails.application.live?
  end

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      # rubocop:disable Rails/Output
      puts message
      # rubocop:enable Rails/Output
    end
  end
end
