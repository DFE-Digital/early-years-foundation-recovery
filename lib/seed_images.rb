# :nocov:
require 'seed_contentful'

# Upload and publish image assets
# @see https://github.com/contentful/contentful-management.rb#assets
#
class SeedImages < SeedContentful
  # @return [Array<String>]
  def call
    log "space: #{config.space}"
    log "env: #{config.environment}"
    log "#{image_files.count} assets found -------------------------------------------"

    image_files.map do |file_path|
      remote_path = "/assets/#{file_path.split('/').last}"
      asset = create_asset(remote_path, remote_path)
      log_asset(asset)
    end

    log "#{assets_count} assets seeded -------------------------------------------"
  end

private

  # @return [String]
  IMG_HOST = 'https://ey-recovery-dev.london.cloudapps.digital'.freeze

  # @param asset [Contentful::Management::Asset]
  # @return [String]
  def log_asset(asset)
    timestamp = asset.published_at&.strftime('%F %T')

    log "'#{asset.description}' published @ '#{timestamp}'"
  end

  # @note multiple runs supported (1. create 2. publish 3. skip)
  # @param title [String]
  # @param filename [String]
  # @return [Contentful::Management::Asset]
  def create_asset(title, filename)
    if (asset = find_asset(filename))
      asset.published? ? asset : asset.publish
    else
      file  = create_file(filename)
      asset = assets.create(title: title, description: filename, file: file)
      asset.process_file
    end
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

  # @return [Array<String>] ~200
  def image_files
    Dir[Rails.root.join('app/assets/images/*')]
  end

  # @return [Integer]
  def assets_count
    assets.all(limit: 1_000).count
  end
end
# :nocov:
