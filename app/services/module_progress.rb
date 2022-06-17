# User's module progress and submodule/topic state
#
class ModuleProgress
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user

  def items
    @mod.items_by_submodule.except(nil).map {|num, items| [num, items]}.to_h
  end

  # @return [Boolean]
  def all?(items)
    state(:all?, items)
  end

  def any?(items)
    state(:any?, items)
  end

  def none?(items)
    state(:none?, items)
  end

  # Name of last page viewed in module
  # @return [String]
  def milestone
    page = training_module_events.last
    page.properties['id'] if page.present?
  end

private

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
