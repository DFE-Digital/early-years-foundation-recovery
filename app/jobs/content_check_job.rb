# :nocov:
class ContentCheckJob < ApplicationJob
  # @return [Boolean]
  def run(*)
    Training::Module.cache.clear
    log "Running in '#{env}' via '#{api}'"
    valid?
  end

private

  # @return [Boolean] are all modules valid
  def valid?
    Training::Module.ordered.all? do |mod|
      check = ContentIntegrity.new(module_name: mod.name)
      check.call # print results
      log Training::Module.cache.size # should be larger than 0

      unless check.valid?
        log "#{mod.name} in '#{env}' via '#{api}' is not valid", :warn
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
end
# :nocov:
