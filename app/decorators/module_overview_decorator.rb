class ModuleOverviewDecorator < DelegateClass(ModuleProgress)
  # Symbol, TrainingModule, String/Nil
  # @yield [Array] locales key and content page
  def call_to_action
    if completed?
      yield(:completed, [mod, mod.last_page])
    elsif failed_attempt?
      yield(:failed, [mod, nil])
    elsif started?
      yield(:started, [mod, resume_page])
    else
      yield(:not_started, [mod, mod.interruption_page])
    end
  end

  # @return [Array<String, Symbol, Array>]
  def topics_by_submodule
    mod.items_by_submodule.map do |num, items|
      intro = items.first
      content = items[1..]
      [
        num,                                  # submodule digit
        intro.model.heading,                  # submodule intro heading
        previous_submodule_heading_text(num), # previous submodule heading
        status(content),                      # symbol - all content pages in the submodule
        topics(submodule: num, items: items), # Array(String, Symbol)
      ]
    end
  end

  # Check every item has been visited (public for debugging)
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

  def module_completed_at
    completed_at.to_date.strftime('%-d %B %Y')
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

  # @param submodule [String]
  # @param topic_item [ModuleItem]
  #
  # @return [Array<Array>]
  def accordion_content(submodule:, topic_item:)
    topic_status = status(topic_item.current_submodule_topic_items)

    # providing the next page name enables the hyperlink
    if clickable?(topic_item: topic_item, submodule: submodule)
      next_item_name = topic_status.eql?(:started) ? resume_page : topic_item
    end

    # SummativeAssessmentProgress conditional pass
    if failed_attempt?
      topic_status = :failed if topic_item.assessment_intro?
      next_item_name = nil if topic_item.confidence_intro?
    elsif successful_attempt?
      topic_status = :completed if topic_item.assessment_intro?
      next_item_name = topic_item if topic_item.confidence_intro?
    end

    [
      topic_item.training_module,   # TrainingModule [mod]
      topic_item.model.heading,     # String (content page heading) [topic_heading]
      next_item_name,               # String/nil (module_item name) [next_item]
      topic_status,                 # Symbol (all items viewed) [status]
    ]
  end

  # @param submodule [String]
  # @param topic_item [ModuleItem]
  #
  # @return [Boolean]
  def clickable?(submodule:, topic_item:)
    submodule_intro = mod.module_items_by_submodule(submodule).first
    return false unless visited?(submodule_intro)

    current_topic = find_current_topic(topic_item.topic_name, submodule)
    current_topic_items = current_topic.values.first.to_a

    previous_submodule = find_previous_submodule(topic_item.submodule_name)
    previous_submodule_items = previous_submodule.values.first.to_a

    if current_topic && previous_submodule
      all?(current_topic_items) && all?(previous_submodule_items)
    else
      all?([topic_item])
    end
  end

  # @param num [String]
  #
  # @return [String]
  def previous(num)
    (num.to_i - 1).to_s
  end

  # @param num [String]
  #
  # @return [Array<Array>] ['1'] [item, item, item]
  def find_previous_submodule(num)
    mod.items_by_submodule.select do |sub_num, _|
      previous(num).eql?(sub_num)
    end
  end

  # @param current_top_num [String]
  # @param current_sub_num [String]
  #
  # @return [Array<Array>] [1,2] [item, item, item]
  def find_current_topic(current_top_num, current_sub_num)
    mod.items_by_topic.select do |(sub_num, topic_num), _items|
      sub_num.eql?(current_sub_num) && current_top_num.eql?(topic_num)
    end
  end

  # @param num [String]
  #
  # @return [String]
  def previous_submodule_heading_text(num)
    find_previous_submodule(num).map { |_, items| items.first.model.heading }.first
  end

  #
  # @return [TrainingModule, nil]
  def previous_module
    TrainingModule.find_by(id: mod.id - 1)
  end
end
