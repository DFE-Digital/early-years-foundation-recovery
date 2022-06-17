# User's module progress and submodule/topic state
#
class ModuleProgress
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user

  # @yield [Array]
  def call_to_action
    if completed?
      yield(:completed, [@mod, @mod.test_page])
    elsif started?
      yield(:started, [@mod, milestone])
    else
      yield(:not_started, [@mod, @mod.interruption_page])
    end
  end

  # @return [Array]
  def topics_by_submodule
    @mod.items_by_submodule.except(nil).map do |num, items|
      prev_num = (num.to_i - 1).to_s

      prev = @mod
        .items_by_submodule
        .select { |sub_num, _| sub_num == prev_num }
        .map { |_, prev_items| prev_items.first.model.heading }.first

      intro = items.first # submodule intro
      topics = items[1..].select(&:topic?) # exclude intro or subpages

      [
        num,                    # submodule digit
        intro.model.heading,    # intro heading
        status(topics),         # symbol
        prev,

        topics.map do |i|
          [
            i.training_module,  # training module
            i,                  # topic module item
            i.model.heading,    # topic page heading
            all?([i]),          # boolean
            status([i]),        # symbol
          ]
        end,
      ]
    end
  end

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

  # @return [Symbol]
  def status(items)
    if all?(items)
      :completed
    elsif any?(items)
      :started
    elsif none?(items)
      :not_started
    else
      :unknown
    end
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
