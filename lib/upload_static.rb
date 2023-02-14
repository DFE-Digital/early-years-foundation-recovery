# :nocov:
require 'contentful/management'

#
# Populate Contentful using YAML content
#
class UploadStatic
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

  # @return [String]
  def call(type:)
    log "space: #{config.space}"
    log "env: #{config.environment}"

    unless type.eql?('static')
      log "'#{type}' was not found"
      return
    end

    log "#{type} ----------------------------------------------------------"

    I18n.t('static').map do |slug, page_info|
      static_page = create_static_page({
        name: slug.to_s.dasherize,
        heading: page_info[:heading],
        body: page_info[:content],
        html_title: page_info[:heading],
      })

      log_entry(static_page)
    end
  end

private

  # @param message [String]
  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end

  # @param entry [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_entry(entry)
    type = entry.sys[:contentType].id
    timestamp = entry.sys[:createdAt]&.strftime('%F %T')

    log "'#{type}' entry '#{entry.name}' published @ '#{timestamp}'"
  end

  # @return [Contentful::Management::DynamicEntry[trainingModule]]
  def create_static_page(params)
    factory.find('static').entries.create(params)
  end

  # @return [Contentful::Management::ClientContentTypeMethodsFactory]
  def factory
    @factory ||= client.content_types(config.space, config.environment)
  end
end
# :nocov:
