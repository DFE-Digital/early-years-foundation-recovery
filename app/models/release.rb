# Persisted webhook payloads from CMS
#
class Release < ApplicationRecord
  # @return [nil, String]
  def self.cache_key
    release = order(:id).last
    timestamp = release&.time&.strftime('%d-%m-%Y-%H-%M')
    "#{timestamp}-#{release.id}" if timestamp
  end

  default_scope { order(time: :asc) }
end
