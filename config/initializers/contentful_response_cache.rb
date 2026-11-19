require 'digest'

# Cache HTTP data rather than SDK models so each worker hydrates its own entries.
module ContentfulResponseCache
  def get_http(url, query, headers = {}, proxy = {}, timeout = {})
    return super if Rails.cache.is_a?(ActiveSupport::Cache::NullStore) || URI.parse(url).host != 'cdn.contentful.com'

    data = Rails.cache.fetch(response_cache_key(url, query, headers), expires_in: 1.hour, race_condition_ttl: 10) do
      response = super
      return response unless response.status == 200

      {
        status: response.status.to_i,
        version: response.version,
        headers: response.headers.to_h,
        body: response.to_s,
      }
    end

    HTTP::Response.new(data)
  end

private

  def response_cache_key(url, query, headers)
    query = Array(query).sort_by { |key, _value| key.to_s }
    fingerprint = Digest::SHA256.hexdigest([url, query, headers['Authorization']].to_json)

    ['contentful', 'responses', 'v1', Page.cache_key, fingerprint]
  end
end

Rails.application.config.to_prepare do
  Contentful::Client.singleton_class.prepend(ContentfulResponseCache)
end
