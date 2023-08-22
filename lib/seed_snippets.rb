# :nocov:
require 'seed_contentful'

class SeedSnippets < SeedContentful
  # @return [String]
  def call
    log "space: #{config.space}"
    log "env: #{config.environment}"

    return locales if Rails.env.test?

    locales.each do |params|
      resource = create_resource(params)
      resource.publish if resource.save
      log_resource(resource)
    end
  end

private

  # @param resource [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_resource(resource)
    timestamp = resource.published_at&.strftime('%F %T')

    log "'#{resource.name}' published @ '#{timestamp}'"
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[resource]]
  def create_resource(params)
    content_types.find('resource').entries.create(params)
  end

  # @return [Array<Hash>]
  def locales
    to_params(data).map do |name, body|
      { name: name.join('.'), body: body }
    end
  end

  # @return [Hash]
  def data
    YAML.load_file('config/locales/en.yml')['en'] # custom only
  end

  # @return [Array<Array>]
  def to_params(data, keys = [], result = [])
    if data.is_a?(Hash)
      data.each do |key, value|
        to_params(value, keys + [key], result)
      end
    else
      result << [keys]
      result.last << data
    end
    result
  end
end
# :nocov:
