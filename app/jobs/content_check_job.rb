# ContentCheckJob.enqueue
#
class ContentCheckJob < Que::Job
  def run(mod:)
    log "Running ContentCheckJob: mod=#{mod}"

    ContentfulDataIntegrity.new(training_module: mod).valid?
  end

  def handle_error(error)
    message = "ContentCheckJob Failed: #{error.message}"
    log(message)
    Sentry.capture_message(message) if Rails.application.live?
  end

private

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
