class DuplicateJobChecker < Que::Job
  def run
    return if duplicate_job_queued?

    super
  end

private

  def duplicate_job_queued?
    Que.job_stats.any? { |job| job[:job_class] == self.class.name && job[:count] > 1 }
  end

  # @return [String]
  def log_duplicate
    Rails.logger.info("DuplicateJobChecker: Duplicate #{self.class.name} job queued - skipping")
    Sentry.capture_message("DuplicateJobChecker: Duplicate #{self.class.name} job queued - skipping") if Rails.application.live?
    puts "DuplicateJobChecker: Duplicate #{self.class.name} job queued - skipping"
  end
end
