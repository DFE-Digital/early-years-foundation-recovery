# OPTIMIZE: N+1 query
#
# Overall module progress:
#   - whether a page was visited
#   - whether any/all/no pages in a section were visited
#   - whether key events have been recorded (start/complete)
#   - the last page visited
#   - the furthest page visited
#
class ModuleProgress
  # extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  # option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  # option :mod, Types::TrainingModule, required: true
  # @!attribute [r] summative_assessment
  #   @return [AssessmentProgress]
  # option :summative_assessment, default: proc { AssessmentProgress.new(user: user, mod: mod) }
  def initialize(mod:, events:, assessment:)
    @mod = mod
    @training_module_events = events
    @summative_assessment = AssessmentProgress.new(mod: mod, assessment: assessment)
  end

  # @return [Float] Module completion
  def value
    visited.size.to_f / mod.content.size
  end

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = module_page_events.last
    page.properties['id'] if page.present?
  end

  # Assumes gaps in page views due to skipping or revisions to content
  # @return [Training::Page, Training::Question, Training::Video]
  def furthest_page
    visited.last
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def resume_page
    mod.page_by_name(milestone) || mod.first_content_page
  end

  # @see CourseProgress
  # @return [Boolean]
  def completed?
    key_event('module_complete').present?
  end

  # @see CourseProgress
  # @return [Boolean]
  def started?
    key_event('module_start').present?
  end

  # @param page [Training::Page, Training::Question, Training::Video]
  # @return [Boolean]
  def visited?(page)
    content_events_count(page.name).positive?
  end

  # Completed date for module
  # @return [DateTime, nil]
  def completed_at
    key_event('module_complete')&.time
  end

protected

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] all items viewed
  def all?(content)
    state(:all?, content)
  end

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] some items viewed
  def any?(content)
    state(:any?, content)
  end

  # @see ModuleOverviewDecorator
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  # @return [Boolean] no items viewed
  def none?(content)
    state(:none?, content)
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def failed_attempt?
    summative_assessment.attempted? && summative_assessment.failed?
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def successful_attempt?
    summative_assessment.passed?
  end

  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def visited
    mod.content.select { |page| visited?(page) }
  end

  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def unvisited
    mod.content.reject { |page| visited?(page) }
  end

private

  attr_reader :mod, :training_module_events, :summative_assessment

  # @param method [Symbol]
  # @param content [Array<Training::Page, Training::Question, Training::Video>]
  #
  # @return [Boolean]
  def state(method, content)
    content.send(method) { |page| visited?(page) }
  end

  # @param name [String]
  # @return [Integer]
  def content_events_count(name)
    training_module_events.count { |e| e.id == name }
  end

  # @return [Event::ActiveRecord_AssociationRelation]
  def module_page_events
    training_module_events.select { |e| e.name == 'module_content_page' }
  end

  # @param key [String] module_start, module_complete
  # @return [Event]
  def key_event(key)
    training_module_events.detect { |e| e.name == key }
  end
end
