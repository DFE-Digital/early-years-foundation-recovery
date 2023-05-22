# :nocov:
require 'contentful/management'
require 'seed_course_entries'

#
# Extract and upload image assets from markdown
#
class SeedImages < SeedCourseEntries
  # @return [String]
  # rubocop:disable Rails/SaveBang
  def call(mod_name:)
    log "space: #{config.space}"
    log "env: #{config.environment}"

    mod = find_mod(mod_name)

    if mod.blank?
      log "Module '#{mod_name}' was not found"
      return
    end

    log "#{mod.name} ----------------------------------------------------------"

    mod.module_items.map do |item|
      # Media upload if found in body copy
      match_data_array = scan_for_images(item.model.body)

      while match_data_array.any?
        match_data = match_data_array.first
        asset = process_image(*match_data.captures)
        asset.publish
        if asset.image_url.present?
          log "Image: #{match_data[:filename]} for #{item.model.name} succeeded"
          match_data_array.shift
        else
          asset.destroy
        end
      end
    end
  end
  # rubocop:enable Rails/SaveBang
end
