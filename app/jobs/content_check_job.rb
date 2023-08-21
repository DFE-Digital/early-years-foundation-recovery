# :nocov:
class ContentCheckJob < Que::Job
  # @return [Boolean]
  def run(*)
    Training::Module.cache.clear
    log "#{self.class.name}: Running in '#{env}' via '#{api}'"
    valid?
  end

  def handle_error(error)
    message = "#{self.class.name}: Failed with '#{error.message}'"
    log(message)
    Sentry.capture_message(message)
  end

private

  # @return [Boolean] are all modules valid
  def valid?
    Training::Module.ordered.all? do |mod|
      check = ContentIntegrity.new(module_name: mod.name)
      check.call # print results
      log Training::Module.cache.size # should be larger than 0

      unless check.valid?
        message = "ContentCheckJob: #{mod.name} in '#{env}' via '#{api}' is not valid"
        log(message)
        Sentry.capture_message(message)
      end

      check.valid?
    end
  end

  # @return [String]
  def env
    ContentfulRails.configuration.environment
  end

  # @return [String]
  def api
    ContentfulModel.use_preview_api ? 'preview' : 'delivery'
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
