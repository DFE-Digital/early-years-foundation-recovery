# FillPageViewsJob.enqueue
#
class FillPageViewsJob < Que::Job
  self.queue = 'default'
  self.priority = 1
  # self.run_at = proc { 1.minute.from_now }
  self.maximum_retry_count = 3

  def run(*)
    require 'fill_page_views'
    Training::Module.cache.clear
    log 'FillPageViewsJob: Running'
    FillPageViews.new.call
  end

  def handle_error(error)
    message = "FillPageViewsJob: Failed with '#{error.message}'"
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
