# :nocov:
require 'seed_contentful'

class SeedUserSettings < SeedContentful
  # @return [String]
  def call
    log "space: #{config.space}"
    log "env: #{config.environment}"

    settings.each do |params|
      setting = create_setting(params)
      setting.publish if setting.save
      log_entry(setting)
    end
  end

private

  # @param entry [Contentful::Management::DynamicEntry]
  # @return [String]
  def log_entry(entry)
    timestamp = entry.published_at&.strftime('%F %T')

    log "'#{entry.name}' published @ '#{timestamp}'"
  end

  # @param params [Hash]
  # @return [Contentful::Management::DynamicEntry[userSetting]]
  def create_setting(params)
    content_types.find('userSetting').entries.create(params)
  end

  # @return [Array<Hash>]
  def settings
    data.map do |yaml|
      {
        name: yaml['id'],
        title: yaml['name'],
        role_type: yaml['role_type'],
        local_authority: yaml['local_authority'],
      }
    end
  end

  # @return [Array<Hash>]
  def data
    YAML.load_file('data/setting-type.yml')
  end
end
# :nocov:
