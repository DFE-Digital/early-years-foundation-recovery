class Page::Resource < ContentfulModel::Base
  extend ::Caching

  # @return [Concurrent::Map] single shared in-memory cache
  def self.cache
    Training::Module.cache
  end

  # @return [String]
  def self.content_type_id
    'resource'
  end

  # @param name [String]
  # @return [Page::Resource]
  def self.by_name(name)
    fetch_or_store to_key(name) do
      find_by(name: name.to_s).first
    end
  end

  # @return [Array<Page::Resource>]
  def self.ordered
    fetch_or_store to_key("#{name}.__method__") do
      limit(1_000).order(:name).load.to_a
    end
  end
end
