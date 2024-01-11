class Course < ContentfulModel::Base
  validates_presence_of :service_name, :privacy_policy_url, :internal_mailbox
  # validates :service_name, :privacy_policy_url, :internal_mailbox, presence: true

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
  def first
    fetch_or_store('course') { super }
  end
end
