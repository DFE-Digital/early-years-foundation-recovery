# :nocov:
class DashboardJob < Que::Job
  # Jobs will default to priority 100 and run immediately
  # a lower number is more important
  #
  # self.queue = 'default'
  # self.run_at = proc { 1.minute.from_now }
  # self.priority = 10

  # @param upload [Boolean] defaults to true in production or if $DASHBOARD_UPDATE exists
  def run(upload: Rails.application.dashboard?)
    log "#{self.class.name}: Running upload=#{upload}"

    Dashboard.new(path: build_dir).call(upload: upload, clean: true)
  end

  def handle_error(error)
    message = "#{self.class.name}: Failed with '#{error.message}'"
    log(message)
    Sentry.capture_message(message) if Rails.application.live?
  end

private

  # @return [Pathname]
  def build_dir
    Rails.root.join('tmp')
  end

  # @param message [String]
  # @return [String, nil]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    elsif ENV['VERBOSE'].present?
      puts message
    end
  end
end
# :nocov:
