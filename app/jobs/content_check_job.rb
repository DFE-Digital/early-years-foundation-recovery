# ContentCheckJob.enqueue
#
class ContentCheckJob < Que::Job
  # @return [Boolean]
  def run(*)
    refresh!
    log "ContentCheckJob: Running in '#{env}' via '#{api}'"
    valid?
  end

  def handle_error(error)
    message = "ContentCheckJob: Failed with '#{error.message}'"
    log(message)
    Sentry.capture_message(message)
  end

private

  def refresh!
    if Training::Module.cache?
      Training::Module.reset_cache!
    else
      log 'CACHING DISABLED'
    end
  end

  # @return [Boolean] are all modules valid
  def valid?
    Training::Module.ordered.all? do |mod|
      check = ContentfulDataIntegrity.new(module_name: mod.name)
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
    # ContentfulRails.configuration.enable_preview_domain ? 'preview' : 'delivery'
  end

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
