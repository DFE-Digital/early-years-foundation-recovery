# User's module progress and submodule/topic state
#
class ModuleProgress
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user, :mod

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = training_module_events.last
    page.properties['id'] if page.present?
  end

  # Last visited module item
  # @return [ModuleItem]
  def resume_page
    unvisited.first&.previous_item
  end

  # @see CourseProgress
  # @return [Boolean]
  def completed?
    all?(mod.module_items)
  end

  # @see CourseProgress
  # @return [Boolean] module pages have been viewed (past interruption)
  def started?
    visited?(mod.intro_page)
  end

# @return [Boolean] previous module completed
# def ready_to_start?
#   previous_module ? all?(previous_module.module_items) : true
# end

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

  # @return [Boolean] view event logged for page
  def visited?(page)
    training_module_events.where_properties(id: page.name).present?
  end

private

  # @return [Array<ModuleItem>]
  def unvisited
    @unvisited ||= mod.module_items.select { |item| module_item_events(item.name).none? }
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
