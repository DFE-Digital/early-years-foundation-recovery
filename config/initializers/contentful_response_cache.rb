require 'digest/sha1'

module ContentfulResponseCache
  CachedResponse = Struct.new(:status, :body, :headers) do
    delegate :to_s, to: :body
  end

  TTL = 1.hour
  KEY_PREFIX = 'contentful:response'.freeze
  DELIVERY_HOST = 'cdn.contentful.com'.freeze

  def get_http(url, query, headers = {}, proxy = {}, timeout = {})
    return super unless cacheable_contentful_request?(url)

    key = contentful_response_key(url, query)
    cached = Rails.cache.read(key)
    return CachedResponse.new(cached[:status], cached[:body], cached[:headers]) if cached

    response = super
    return response unless response.status == 200

    payload = {
      status: response.status,
      body: response.to_s,
      headers: { 'Content-Encoding' => response.headers['Content-Encoding'] },
    }
    Rails.cache.write(key, payload, expires_in: TTL)
    CachedResponse.new(payload[:status], payload[:body], payload[:headers])
  end

private

  def cacheable_contentful_request?(url)
    Rails.cache.present? &&
      !Rails.cache.is_a?(ActiveSupport::Cache::NullStore) &&
      url.to_s.include?(DELIVERY_HOST)
  end

  def contentful_response_key(url, query)
    query_string = Array(query).sort_by { |key, _value| key.to_s }
    digest = Digest::SHA1.hexdigest("#{url}?#{query_string}")
    "#{KEY_PREFIX}:#{Page.cache_key}:#{digest}"
  end
end

Rails.application.config.to_prepare do
  Contentful::Client.singleton_class.prepend(ContentfulResponseCache)
end
