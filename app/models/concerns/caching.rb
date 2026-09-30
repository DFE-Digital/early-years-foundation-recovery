#
# Use in-process object caching and a shared cache version when Redis is configured.
# @see https://github.com/dry-rb/dry-core/blob/main/lib/dry/core/cache.rb
#
module Caching
  # @api private
  def self.extended(klass)
    klass.send :extend, Dry::Core::Cache
  end

  # @param key [String] entry id / collection
  # @return [String] timestamped cache key
  def to_key(key)
    "#{key}-#{cache_key}"
  end

  # @return [String] default "initial"
  def cache_key
    return cache.get_or_default('cache_key', 'initial') unless shared_cache?

    Rails.cache.fetch(shared_cache_key, expires_in: 30.days) do
      cache.get_or_default('cache_key', 'initial')
    end
  end

  # memoise latest release timestamp & prevent cache overload
  # (increase as CMS entries/assets grow)
  #
  # @return [String] old key
  def reset_cache_key!
    cache.clear if cache.size > 2_000
    new_key = Release.cache_key || cache_key

    return cache.get_and_set('cache_key', new_key) unless shared_cache?

    old_key = cache_key
    Rails.cache.write(shared_cache_key, new_key, expires_in: 30.days)
    old_key
  end

private

  def shared_cache?
    Rails.cache.present? && !Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
  end

  def shared_cache_key
    "#{name.underscore}:cache_key"
  end
end
