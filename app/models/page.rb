class Page < ContentfulModel::Base
  extend Dry::Core::Cache

  # @return [String]
  def self.content_type_id
    'static'
  end

  # @param name [String]
  # @return [?]
  def self.by_name(name)
    fetch_or_store(name) do
      load_children(0).find_by(name: name.to_s).first
    end
  end

  # @return [?]
  def self.footer
    fetch_or_store(__method__) do
      load_children(0).find_by(footer: true).order(:heading).load
    end
  end

  # Deprecate
  def model
    self
  end
end
