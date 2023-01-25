require 'contentful/management'

#
# Populate Contentful using YAML content
#
class Upload
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

  # @return [String]
  def call(mod_name:)
    # log "space: #{config.space}"
    # log "env: #{config.environment}"

    mod = find_mod(mod_name)

    if mod.blank?
      log "Module '#{mod_name}' was not found"
      return
    end

    log "#{mod.name} ----------------------------------------------------------"

    mod_entry = create_training_module(mod.cms_module_params)

    mod_entry.pages =
      mod.module_items.map do |item|
        child_entry = create_entry(item)
        child_entry.publish # TODO: current video fails due to provider not being read correctly
        log_entry(child_entry)
        child_entry
      end

    mod_entry.publish if mod_entry.save

    log_entry(mod_entry)
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
    log "'#{entry.sys[:contentType].id}' entry '#{entry.name}' published @ '#{entry.published_at&.strftime('%F %T')}'"
  end

  # YAML -----------------------------------------------------------------------

  # @param name [String]
  # @return [TrainingModule]
  def find_mod(name)
    TrainingModule.find_by(name: name)
  end

  # CONTENTFUL -----------------------------------------------------------------

  # ModuleItem has 3 methods "cms_<model>_params" which return CMS ready attrbiutes
  #
  # @param [ModuleItem]
  # @return [Contentful::Management::DynamicEntry]
  def create_entry(item)
    case item.type
    when /video/
      create_video(item.cms_video_params)
    when /question/
      create_question(item.cms_question_params)
    else
      create_page(item.cms_page_params)
    end
  end

  # @return [Contentful::Management::DynamicEntry[trainingModule]]
  def create_training_module(params)
    factory.find('trainingModule').entries.create(params)
  end

  # @return [Contentful::Management::DynamicEntry[page]]
  def create_page(params)
    factory.find('page').entries.create(params)
  end

  # @return [Contentful::Management::DynamicEntry[video]]
  def create_video(params)
    factory.find('video').entries.create(params)
  end

  # @return [Contentful::Management::DynamicEntry[question]]
  def create_question(params)
    factory.find('question').entries.create(params)
  end

  # @return [Contentful::Management::ClientContentTypeMethodsFactory]
  def factory
    @factory ||= client.content_types(config.space, config.environment)
  end
end
