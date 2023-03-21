# :nocov:
require 'contentful/management'

#
# Populate Contentful 'static' entries
#
class SeedStaticPageEntries
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

  # @return [String]
  def call(*)
    log "space: #{config.space}"
    log "env: #{config.environment}"

    I18n.t('pages').map do |slug, fields|
      entry = create_static_page(name: slug.to_s.dasherize, **fields)
      entry.publish if entry.save
      log_entry(entry)
    end
  end

private

  # @param entry [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_entry(entry)
    type = entry.sys[:contentType].id
    timestamp = entry.published_at&.strftime('%F %T')

    log "'#{type}' entry '#{entry.name}' published @ '#{timestamp}'"
  end

  # @param message [String]
  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end

  # @return [Contentful::Management::DynamicEntry[static]]
  def create_static_page(params)
    factory.find('static').entries.create(params)
  end

  # @return [Contentful::Management::ClientContentTypeMethodsFactory]
  def factory
    @factory ||= client.content_types(config.space, config.environment)
  end
end
# :nocov:
