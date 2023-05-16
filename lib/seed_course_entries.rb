# :nocov:
require 'contentful/management'

#
# Populate Contentful 'page', 'video', 'question' and 'trainingModule' entries
# Extract and upload image assets from markdown
#
class SeedCourseEntries
  extend Dry::Initializer

  option :config, default: proc { ContentfulRails.configuration }
  option :client, default: proc { Contentful::Management::Client.new(config.management_token) }

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

    mod_entry.pages =
      mod.module_items.map do |item|
        child_entry = create_entry(item)

        # Media upload if found in body copy

        scan_for_images(item.model.body).each do |image|
          asset = process_image(*image.captures)
          if asset.save
            log "Waiting for image upload: #{image[:filename]} for #{item.model.name}"
            10.times do |i|
              next if asset.image_url.present?
              sleep 1
              asset.publish
            end
            if asset.image_url.present?
              child_entry.body = item.model.body.gsub(image[:filename], asset.image_url)
              log "Uploaded image: #{image[:filename]} for #{item.model.name} -> #{asset.image_url}"
            else
              child_entry.body = item.model.body.gsub(image[:filename], '#tbd')
              log "Incomplete image: #{image[:filename]} for #{item.model.name}"
            end
          end
        end

        # parent
        child_entry.training_module = mod_entry

        child_entry.publish if child_entry.save
        log_entry(child_entry)
        child_entry
      end

    mod_entry.publish if mod_entry.save

    log_entry(mod_entry)
  end

private

  # @param body  [String]
  # return [Array<MatchData>]
  def scan_for_images(body)
    body&.to_enum(:scan, IMG_REGEXP)&.map { Regexp.last_match }.to_a # Array of MatchData
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

  # Asset Management -----------------------------------------------------------

  IMG_REGEXP = /!\[(?<title>[^\]]*)\]\((?<filename>.*?)\s*("(?:.*[^"])")?\s*\)/
  IMG_HOST = 'https://ey-recovery-dev.london.cloudapps.digital'.freeze

  # @param title [String]
  # @param filename [String]
  # @return [Contentful::Management::Asset]
  def process_image(title, filename)
    file  = create_file(filename)
    asset = create_asset(title: title, description: filename, file: file)
    asset.process_file
  end

  # @return [Contentful::Management::File]
  def create_file(filename)
    file = Contentful::Management::File.new
    file.content_type = 'image/jpeg'
    file.file_name = filename
    file.properties[:upload] = ApplicationController.helpers.image_url(filename, host: IMG_HOST)
    file
  end

  # @return [Contentful::Management::Asset]
  def create_asset(params)
    client.assets(config.space, config.environment).create(params)
  end
end
# :nocov:
