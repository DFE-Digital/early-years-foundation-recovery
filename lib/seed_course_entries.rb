# :nocov:
require 'seed_contentful'

# Populate Contentful 'page', 'video', 'question' and 'trainingModule' entries
# Replace markdown images with CMS hosted assets
#
class SeedCourseEntries < SeedContentful
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
    mod_entry.image = update_image(mod.title, mod.thumbnail)
    mod_entry.pages = create_children(mod_entry, mod.module_items)
    log "#{mod_entry.pages.count} entries linked ------------------------------------------------"

    mod_entry.publish if mod_entry.save
    log_entry(mod_entry)
  end

private

  # @param entry [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_entry(entry)
    type = entry.sys[:contentType].id
    timestamp = entry.published_at&.strftime('%F %T')

    log "'#{type}' entry '#{entry.name}' published @ '#{timestamp}'"
  end

  # @param name [String]
  # @return [TrainingModule]
  def find_mod(name)
    TrainingModule.find_by(name: name)
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[trainingModule]]
  def create_training_module(params)
    content_types.find('trainingModule').entries.create(params)
  end

  # @param mod_entry [Contentful::Management::DynamicEntry[trainingModule]]
  # @param items [Array<ModuleItem>]
  # @return [Array<Contentful::Management::DynamicEntry>]
  def create_children(mod_entry, items)
    items.map do |item|
      child_entry = create_entry(item)

      # Replace relative image links with CMS hosted URLs
      if item.text_page? || item.submodule_intro?
        child_entry.body = replace_images(child_entry.body)
      end

      child_entry.training_module = mod_entry
      child_entry.publish if child_entry.save
      log_entry(child_entry)
      child_entry
    end
  end

  # @param item [ModuleItem]
  # @return [Contentful::Management::DynamicEntry]
  def create_entry(item)
    case item.type
    when /video/    then create_video item.cms_video_params
    when /question/ then create_question item.cms_question_params
    else
      create_page item.cms_page_params
    end
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

  # @return [Regexp]
  IMG_REGEXP = /!\[(?<title>[^\]]*)\]\((?<filename>.*?)\s*("(?:.*[^"])")?\s*\)/

  # @param title [String]
  # @param filename [String, nil]
  # @return [Contentful::Management::Asset, nil]
  def update_image(title, filename)
    return unless filename

    thumbnail = find_asset("/assets/#{filename}")
    thumbnail.title = title
    thumbnail.publish if thumbnail.save
  end

  # @note Ensure all images are first seeded and published
  # @see SeedImages
  # @param body [String]
  # @return [String]
  def replace_images(body)
    images = body.scan(IMG_REGEXP)

    images.each do |title, filename|
      asset = find_asset(filename)

      if asset.image_url.present?
        asset.title = title
        asset.publish if asset.save

        body.gsub!(filename, asset.image_url)
        log "'#{filename}' -> '#{asset.image_url}'"
      else
        log "'#{filename}' skipped"
      end
    end

    body
  end
end
# :nocov:
