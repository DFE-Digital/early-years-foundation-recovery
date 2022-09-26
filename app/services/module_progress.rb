# User's module progress and submodule/topic state
#
class ModuleProgress
  # @param user [User]
  # @param mod [TrainingModule]
  def initialize(user:, mod:)
    @user = user
    @mod = mod
    @summative_assessment = SummativeAssessmentProgress.new(user: user, mod: mod)
  end

  # @!attribute [r] user
  #   @return [User]
  # @!attribute [r] mod
  #   @return [TrainingModule]
  # @!attribute [r] summative_assessment
  #   @return [SummativeAssessmentProgress]
  attr_reader :user, :mod, :summative_assessment

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = training_module_events.last
    page.properties['id'] if page.present?
  end

  # Assumes gaps in page views due to skipping or revisions to content
  # @return [ModuleItem]
  def furthest_page
    visited.last
  end

  # Last visited module item with fallback to first item
  # @return [ModuleItem]
  def resume_page
    unvisited.first&.previous_item || mod.expectation_page
  end

  # @see FillPageViews task
  # @return [Boolean] non-sequential gaps present
  def skipped?
    (unvisited.first.id..unvisited.last.id).count != unvisited.map(&:id).count
  end

  # @see CourseProgress
  # @return [Boolean]
  def completed?
    all?(mod.module_items)
  end

  # Completed date for module
  # @return [DateTime]
  def completed_at
    last_page = mod.module_items.last.name
    training_module_events.where_properties(id: last_page).first.time
  end

  # @see CourseProgress
  # @return [Boolean] module pages have been viewed (past interruption)
  def started?
    visited?(mod.intro_page)
  end

  # @return [Boolean] view event logged for page
  def visited?(page)
    module_item_events(page.name).present?
  end

protected

  # @see ModuleOverviewDecorator
  # @return [Boolean] all items viewed
  def all?(items)
    state(:all?, items)
  end

  # @see ModuleOverviewDecorator
  # @return [Boolean] some items viewed
  def any?(items)
    state(:any?, items)
  end

  # @see ModuleOverviewDecorator
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

private

  # @return [Array<ModuleItem>]
  def visited
    mod.module_items.select { |item| visited?(item) }
  end

  # @return [Array<ModuleItem>]
  def unvisited
    mod.module_items.reject { |item| visited?(item) }
  end

  # @param method [Symbol]
  # @param items [Array<ModuleItem>]
  #
  # @return [Boolean]
  def state(method, items)
    items.send(method) { |item| module_item_events(item.name).present? }
  end

  # @param item_id [String] module item name
  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def module_item_events(item_id)
    user.events.where_properties(training_module_id: mod.name, id: item_id)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events
    user.events.where_properties(training_module_id: mod.name)
  end
end
