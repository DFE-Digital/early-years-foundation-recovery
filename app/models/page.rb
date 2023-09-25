class Page < ContentfulModel::Base
  extend ::Caching

  # @return [Concurrent::Map] single shared in-memory cache
  def self.cache
    Training::Module.cache
  end

  # @return [String]
  def self.content_type_id
    'static'
  end

  # @param name [String]
  # @return [Page]
  def self.by_name(name)
    fetch_or_store to_key(name) do
      load_children(0).find_by(name: name.to_s).first
    end
  end

  # @return [Contentful::Array<Page>]
  def self.footer
    fetch_or_store to_key(__method__) do
      load_children(0).find_by(footer: true).order(:heading).load
    end
  end

  # @see ApplicationHelper#html_title
  # @return [String]
  def title
    heading
  end
end
