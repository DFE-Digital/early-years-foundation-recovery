# :nocov:
# @see https://github.com/contentful/contentful-management.rb
require 'contentful/management'

#
# Populate Contentful 'page', 'video', 'question' and 'trainingModule' entries
# Replace image file paths with CMS remote URLs in page body
#
class SeedCourseEntries
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

  # @return [Array<String>]
  def upload_images
    log "#{image_files.count} assets -------------------------------------------"

    image_files.map do |file_path|
      remote_path = "/assets/#{file_path.split('/').last}"
      asset = create_asset(remote_path, remote_path)
      asset.publish if asset.save
      log_asset(asset)
    end
  end

  # @param mod_name [String]
  # @return [String]
  def call(mod_name:)
    log "space: #{config.space}"
    log "env: #{config.environment}"

    mod = find_mod(mod_name)

    if mod.blank?
      log "Module '#{mod_name}' was not found"
      return
    end

    log "#{mod.name} ----------------------------------------------------------"
    mod_entry = create_training_module(mod.cms_module_params)

    # Link thumbnail image
    thumbnail = find_asset("/assets/#{mod.thumbnail}")
    thumbnail.title = mod.title
    mod_entry.image = thumbnail.save

    # Link content
    mod_entry.pages = create_children(mod_entry, mod.module_items)
    log "#{mod_entry.pages.count} entries linked ------------------------------------------------"

    mod_entry.publish if mod_entry.save
    log_entry(mod_entry)
  end

private

  # @param mod_entry [Contentful::Management::DynamicEntry[trainingModule]]
  # @param items [Array<ModuleItem>]
  # @return [Array<Contentful::Management::DynamicEntry>]
  def create_children(mod_entry, items)
    items.map do |item|
      child_entry = create_entry(item)
      child_entry.body = replace_images(child_entry.body) if item.text_page?
      child_entry.training_module = mod_entry
      child_entry.publish if child_entry.save
      log_entry(child_entry)
      child_entry
    end
  end

  # @param body [String]
  # @return [String]
  def replace_images(body)
    images = body.scan(IMG_REGEXP)

    images.each do |title, filename|
      asset = find_asset(filename)

      if asset.image_url.present?
        asset.title = title
        asset.save

        body.gsub!(filename, asset.image_url)
        log "'#{filename}' -> '#{asset.image_url}'"
      else
        log "'#{filename}' skipped"
      end
    end

    body
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

  # @param asset [Contentful::Management::Asset]
  # @return [String]
  def log_asset(asset)
    timestamp = asset.published_at&.strftime('%F %T')

    log "'#{asset.description}' published @ '#{timestamp}'"
  end

  # @param entry [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_entry(entry)
    type = entry.sys[:contentType].id
    timestamp = entry.published_at&.strftime('%F %T')

    log "'#{type}' entry '#{entry.name}' published @ '#{timestamp}'"
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
  # @param item [ModuleItem]
  # @return [Contentful::Management::DynamicEntry]
  def create_entry(item)
    case item.type
    when /video/
      create_video item.cms_video_params
    when /question/
      create_question item.cms_question_params
    else
      create_page item.cms_page_params
    end
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[trainingModule]]
  def create_training_module(params)
    content_types.find('trainingModule').entries.create(params)
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[page]]
  def create_page(params)
    content_types.find('page').entries.create(params)
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[video]]
  def create_video(params)
    content_types.find('video').entries.create(params)
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[question]]
  def create_question(params)
    content_types.find('question').entries.create(params)
  end

  # @return [Contentful::Management::ClientContentTypeMethodsFactory]
  def content_types
    @content_types ||= client.content_types(config.space, config.environment)
  end

  # Asset Management -----------------------------------------------------------

  IMG_REGEXP = /!\[(?<title>[^\]]*)\]\((?<filename>.*?)\s*("(?:.*[^"])")?\s*\)/
  IMG_HOST = 'https://ey-recovery-dev.london.cloudapps.digital'.freeze

  # @param title [String]
  # @param filename [String]
  # @return [Contentful::Management::Asset]
  def create_asset(title, filename)
    file  = create_file(filename)
    asset = assets.create(title: title, description: filename, file: file)
    asset.process_file
  end

  # @param filename [String]
  # @return [Contentful::Management::File]
  def create_file(filename)
    file = Contentful::Management::File.new
    file.content_type = 'image/jpeg'
    file.file_name = filename
    file.properties[:upload] = ApplicationController.helpers.image_url(filename, host: IMG_HOST)
    file
  end

  # @param description [String]
  # @return [Contentful::Management::Asset]
  def find_asset(description)
    assets.all(limit: image_files.size).find { |asset| asset.description.eql?(description) }
  end

  # @return [Contentful::Management::ClientAssetMethodsFactory]
  def assets
    @assets ||= client.assets(config.space, config.environment)
  end

  # @return [Array<String>] ~200
  def image_files
    Dir[Rails.root.join('app/assets/images/*')]
  end
end
# :nocov:
