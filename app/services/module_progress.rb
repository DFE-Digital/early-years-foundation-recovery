# User's module progress and submodule/topic state
#
class ModuleProgress
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user, :mod

  # @param mod [TrainingModule]
  # @return [Boolean] module content has been viewed
  def started?
    first_page = @mod.first_content_page.name
    training_module_events.where_properties(id: first_page).present?
  end

  # TODO: this state is currently true if the last page was viewed
  #
  # @param mod [TrainingModule]
  # @return [Boolean]
  def completed?
    last_page = @mod.module_items.last.name
    training_module_events.where_properties(id: last_page).present?
  end

  # @return [Boolean] all items viewed
  def all?(items)
    state(:all?, items)
  end

  # @return [Boolean] some items viewed
  def any?(items)
    state(:any?, items)
  end

  # @return [Boolean] no items viewed
  def none?(items)
    state(:none?, items)
  end

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = training_module_events.last
    page.properties['id'] if page.present?
  end

  # Name of next unvisited page
  # @return [String]
  def resume_page
    unvisited.first&.name
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
    user.events.where_properties(training_module_id: @mod.name, id: item_id)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events
    user.events.where_properties(training_module_id: @mod.name)
  end
end
