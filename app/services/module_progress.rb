# Overall module progress:
#   - whether a page was visited
#   - whether any/all/no pages in a section were visited
#   - whether key events have been recorded (start/complete)
#   - the last page visited
#   - the furthest page visited
#
class ModuleProgress
  attr_reader :user, :mod, :user_module_events, :events

  # @param user [User]
  # @param mod [Training::Module]
  def initialize(user:, mod:, user_module_events:)
    @user = user
    @mod = mod
    @events_by_module_name = user_module_events
      .select { |e| e.properties['training_module_id'].present? }
      .group_by { |e| e.properties['training_module_id'].to_s }
    @summative_assessment = AssessmentProgress.new(user: user, mod: mod)
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
    return true if key_event('module_start').present?

    # Fallback: any recorded page view within this module implies the user has started
    module_page_events.any? { |event| %w[module_content_page page_view].include?(event.name) }
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
    @summative_assessment.attempted? && @summative_assessment.failed?
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def successful_attempt?
    @summative_assessment.passed?
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
    module_page_events.count { |event| event.properties['id'] == name }
  end

  # @return [Event::ActiveRecord_AssociationRelation]
  # @note This method is used to fetch events for the current module.

  def module_page_events
    @module_page_events ||= begin
      events = if @events_by_module_name
                 @events_by_module_name[mod.name] || []
               else
                 user.events.where_properties(training_module_id: mod.name)
               end

      # Ensure they're in chronological order
      events.sort_by { |e| e.time || Time.zone.at(0) }
    end
  end

  # @param key [String] module_start, module_complete
  # @return [Event]
  def key_event(key)
    module_page_events.find { |event| event.name == key }
  end
end
