# User's module progress and submodule/topic state
#
class ContentfulModuleProgress
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true
  # @!attribute [r] summative_assessment
  #   @return [ContentfulAssessmentProgress]
  option :summative_assessment, default: proc { ContentfulAssessmentProgress.new(user: user, mod: mod) }

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
  # @return [Training::Content]
  def furthest_page
    visited.last
  end

  # Last visited module item with fallback to first item
  # @return [Training::Content]
  def resume_page
    unvisited.first&.previous_item || mod.first_content_page
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

  # @see ContentfulCourseProgress
  # @return [Boolean]
  def completed?
    key_event('module_complete').present?
  end

  # @see ContentfulCourseProgress
  # @return [Boolean]
  def started?
    key_event('module_start').present?
  end

  # @param page [Training::Module]
  # @return [Boolean] view event logged for page
  def visited?(page)
    module_item_events(page.name).present?
  end

  # Completed date for module
  # @return [DateTime, nil]
  def completed_at
    key_event('module_complete')&.time
  end

protected

  # @see ContentfulModuleOverviewDecorator
  # @return [Boolean] all items viewed
  def all?(items)
    state(:all?, items)
  end

  # @see ContentfulModuleOverviewDecorator
  # @return [Boolean] some items viewed
  def any?(items)
    state(:any?, items)
  end

  # @see ContentfulModuleOverviewDecorator
  # @return [Boolean] no items viewed
  def none?(items)
    state(:none?, items)
  end

  # @see SummativeAssessmentProgress
  #
  # @return [Boolean]
  def failed_attempt?
    summative_assessment.attempted? && summative_assessment.failed?
  end

  # @see SummativeAssessmentProgress
  #
  # @return [Boolean]
  def successful_attempt?
    summative_assessment.attempted? && summative_assessment.passed?
  end

  # In progress modules with new pages that have been skipped
  # @return [Boolean]
  def gaps?
    (unvisited.first.id..unvisited.last.id).count != unvisited.map(&:id).count
  end

private

  # @return [Array<Module::Content>]
  def visited
    mod.content.select { |item| visited?(item) }
  end

  # @return [Array<Module::Content>]
  def unvisited
    mod.content.reject { |item| visited?(item) }
  end

  # @param method [Symbol]
  # @param items [Array<Module::Content>]
  #
  # @return [Boolean]
  def state(method, items)
    items.send(method) { |item| module_item_events(item.name).present? }
  end

  # @param item_id [String] content slug
  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def module_item_events(item_id)
    user.events.where_properties(training_module_id: mod.name, id: item_id)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events
    user.events.where_properties(training_module_id: mod.name)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def module_page_events
    training_module_events.where(name: 'module_content_page')
  end

  # @param key [String] module_start, module_complete
  # @return [Ahoy::Event]
  def key_event(key)
    training_module_events.where(name: key).first
  end
end
