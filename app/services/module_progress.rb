# Overall module progress:
#   - whether a page was visited
#   - whether a page was skipped
#   - whether key events have been recorded (start/complete)
#   - the last page visited
#   - the furthest page visited
#   - the furthest page visited
#
class ModuleProgress
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types::TrainingModule, required: true
  # @!attribute [r] summative_assessment
  #   @return [AssessmentProgress]
  option :summative_assessment, default: proc { AssessmentProgress.new(user: user, mod: mod) }

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
    # unvisited.first&.previous_item || mod.first_content_page
    mod.page_by_name(milestone) || mod.first_content_page
  end

  # Identify new content that has not been seen and would effect module state
  #
  # @see FillPageViews task
  # @return [Boolean]
  def skipped?
    if unvisited.none?
      false
    elsif completed? && unvisited.any? # seen last content page but has gaps
      true
    elsif gaps?
      true
    end
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
    if Rails.application.migrated_answers?
      summative_assessment.attempted? && summative_assessment.failed?
    else
      summative_assessment.attempted? && summative_assessment.failed?
    end
  end

  # @see AssessmentProgress
  # @return [Boolean]
  def successful_attempt?
    if Rails.application.migrated_answers?
      summative_assessment.passed?
    else
      summative_assessment.attempted? && summative_assessment.passed?
    end
  end

  # In progress modules with new pages that have been skipped
  # @return [Boolean]
  def gaps?
    (unvisited.first.id..unvisited.last.id).count != unvisited.map(&:id).count
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
    training_module_events.where_properties(id: name).count
  end

  # @return [Event::ActiveRecord_AssociationRelation]
  def training_module_events
    user.events.where_properties(training_module_id: mod.name)
  end

  # @return [Event::ActiveRecord_AssociationRelation]
  def module_page_events
    training_module_events.where(name: 'module_content_page')
  end

  # @param key [String] module_start, module_complete
  # @return [Event]
  def key_event(key)
    training_module_events.where(name: key).first
  end
end
