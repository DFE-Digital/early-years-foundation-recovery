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
    fetch_or_store(to_key('course')) { first }
  end

  # @return [String] mod.name
  def name
    'course'
  end

  # @return [Array] mod.content_sections
  def content_sections
    Types::EMPTY_ARRAY
  end

  # @return [Array] mod.content_subsections
  def content_subsections
    Types::EMPTY_ARRAY
  end

  # @return [Array<Training::Question, Training::Page>]
  def pages
    feedback.to_a.map do |question|
      question.define_singleton_method(:parent) { Course.config }
      question
    end
  end

  # @return [Array<Training::Question>]
  def feedback_questions
    pages.select(&:feedback_question?)
  end

  # @see Pagination
  # @return [Training::Question]
  def page_by_id(id)
    pages.find { |page| page.id.eql?(id) }
  end

  # @return [Training::Question]
  def page_by_name(name)
    pages.find { |page| page.name.eql?(name) }
  end
end
