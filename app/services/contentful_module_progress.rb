# User's module progress and submodule/topic state
#
class ContentfulModuleProgress
  extend Dry::Initializer

  # @param user [User]
  # @param mod [Training::Module]

  # @!attribute [r] user
  #   @return [User]
  option :user, required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, required: true
  # @!attribute [r] summative_assessment
  #   @return [SummativeAssessmentProgress]
  option :summative_assessment, default: proc { SummativeAssessmentProgress.new(user: user, mod: mod) }

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
    unvisited.first&.previous_item || mod.icons_page
  end

  # Identify new content that has not been seen and would effect module state
  #
  # @see FillPageViews task
  # @return [Boolean]
  def skipped?
    if unvisited.none?
      false
    # elsif key_event('module_complete') && unvisited.any?
    elsif visited?(mod.thankyou_page) && unvisited.any? # seen last content page but has gaps
      true
    elsif gaps?
      true
    end
  end

  # TODO: bypass #all? if a :module_complete event exists
  #
  # @see ContentfulCourseProgress
  # @return [Boolean] true if every page is visited (certificate excluded)
  def completed?
    all?(mod.content) # key_event('module_complete').present?
  end

  # TODO: refactor once every user has a "module_complete" event
  #
  # Completed date for module
  # @return [DateTime, nil]
  def completed_at
    page_name = mod.thankyou_page.name
    page_event = module_item_events(page_name).first
    named_event = key_event('module_complete')
    event = named_event || page_event
    event&.time
  end

  # @see ContentfulCourseProgress
  # @return [Boolean] module pages have been viewed (past interruption)
  def started?
    visited?(mod.intro_page)
  end

  # @return [Boolean] view event logged for page
  def visited?(page)
    module_item_events(page.name).present?
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
