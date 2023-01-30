# User's module progress and submodule/topic state
#
class ContentfulModuleProgress
  # @param user [User]
  # @param mod [Training::Module]
  def initialize(user:, mod:)
    @user = user
    @mod = mod
    @summative_assessment = SummativeAssessmentProgress.new(user: user, mod: mod)
  end

  # @!attribute [r] user
  #   @return [User]
  # @!attribute [r] mod
  #   @return [Training::Module]
  # @!attribute [r] summative_assessment
  #   @return [SummativeAssessmentProgress]
  attr_reader :user, :mod, :summative_assessment

  # @return [Float] Module completion
  def value
    visited.size.to_f / mod.content.size
  end

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = training_module_events.last
    page.properties['id'] if page.present?
  end

  # Assumes gaps in page views due to skipping or revisions to content
  # @return [Training::Content]
  def furthest_page
    visited.last
  end

  # @return [String]
  def final_content_page
    mod.last_page.name
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
    elsif module_item_events(final_content_page).first && unvisited.any?
      true
    elsif gaps?
      true
    end
  end

  # @see ContentfulCourseProgress
  # @return [Boolean]
  def completed?
    all?(mod.content)
  end

  # Completed date for module
  # @return [DateTime, nil]
  def completed_at
    certificate_achieved_at || last_page_completed_at
  end

  # @return [DateTime, nil]
  def certificate_achieved_at
    key_event('module_complete')&.time
  end

  # @return [DateTime, nil]
  def last_page_completed_at
    module_item_events(final_content_page).first&.time
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

  # @param item_id [String] module item name
  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def module_item_events(item_id)
    user.events.where_properties(training_module_id: mod.name, id: item_id)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events
    user.events.where_properties(training_module_id: mod.name)
  end

  # @param key [String] module_start, module_complete
  # @return [Ahoy::Event]
  def key_event(key)
    training_module_events.where(name: key).first
  end
end
