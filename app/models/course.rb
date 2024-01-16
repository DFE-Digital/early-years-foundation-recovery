class Course < ContentfulModel::Base
  validates_presence_of :service_name, :privacy_policy_url, :internal_mailbox

  extend ::Caching

  # @return [Concurrent::Map] single shared in-memory cache
  def self.cache
    Training::Module.cache
  end

  # @return [String]
  def self.content_type_id
    'course'
  end

  # @return [Course]
  def self.config
    fetch_or_store('course') { first }
  end

  # @return [Array<Training::Question>]
  def feedback
    super.to_a
  end
end
