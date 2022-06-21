class ModuleOverviewDecorator < DelegateClass(ModuleProgress)
  # @return [Boolean] previous module completed
  # def ready_to_start?
  #   previous_module ? all?(previous_module.module_items) : true
  # end

  # @yield [Array]
  def call_to_action
    if completed?
      yield(:completed, [mod, mod.test_page])
    elsif started?
      yield(:started, [mod, resume_page])
    else
      yield(:not_started, [mod, mod.interruption_page])
    end
  end

  # @return [Array<String, Symbol, Array>]
  def topics_by_submodule
    mod.items_by_submodule.map do |num, items|
      [
        num,                                  # submodule digit
        items.first.model.heading,            # submodule intro heading
        prev_sub_heading_text(num),           # previous submodule heading
        status(items),                        # symbol  - all items in the submodule
        topics(submodule: num, items: items), # Array(String, Symbol)
      ]
    end
  end

  # public for debugging only?
  #
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

private

  # exclude intro or subpages
  #
  # @return [Array<String, Symbol, Array>]
  #
  # @param submodule [String]
  # @param items [Array<ModuleItems]
  def topics(submodule:, items:)
    items[1..].select(&:topic?).map do |topic|
      accordion_content(submodule: submodule, topic_item: topic)
    end
  end

  # @param topic [ModuleItem]
  # @param submodule [String]
  #
  # @return [Array<String, Symbol>]
  def accordion_content(submodule:, topic_item:)
    topic_status = status(topic_item.current_submodule_topic_items)

    if clickable?(topic_item: topic_item, submodule: submodule)
      next_item_name = topic_status.eql?(:started) ? milestone : topic_item
    end

    [
      topic_item.training_module,   # string (module name)
      topic_item.model.heading,     # string (content page heading)
      next_item_name,               # string (module_item name)
      topic_status,                 # symbol (all items viewed)
    ]
  end

  #
  # link logic and value
  #
  # @param submodule [String]
  # @param topic_item [ModuleItem]
  #
  # @return [Boolean] completed or previous mod completed
  def clickable?(submodule:, topic_item:)
    _previous_topic = previous_topic(topic_item.topic_name, submodule)
    _previous_topic_items = _previous_topic.values.first.to_a

    _previous_submodule = prev_submodule(topic_item.submodule_name)
    _previous_submodule_items = _previous_submodule.values.first.to_a

    if _previous_topic && _previous_submodule
      all?(_previous_topic_items) && all?(_previous_submodule_items)
    else
      all?([topic_item])
    end
  end

  # @param num [String]
  # @return [String]
  def previous(num)
    (num.to_i - 1).to_s
  end

  # @param current_top_num [?]
  # @param current_sub_num [?]
  #
  # @return [Array<Array>] [1,2] [item, item, item]
  def previous_topic(current_top_num, current_sub_num)
    mod.items_by_topic.select do |(sub_num, topic_num), _items|
      sub_num.eql?(current_sub_num) && previous(current_top_num).eql?(topic_num)
    end
  end

  # @param num [?]
  #
  # @return [?]
  def prev_sub_heading_text(num)
    prev_submodule(num).map { |_, prev_items|
      prev_items.first.model.heading
    }.first
  end

  # @return [Array<Array>] ['1'] [item, item, item]
  def prev_submodule(num)
    mod.items_by_submodule.select do |sub_num, _|
      previous(num).eql?(sub_num)
    end
  end

  #
  # @return [TrainingModule, nil]
  def previous_module
    TrainingModule.find_by(id: mod.id - 1)
  end
end
