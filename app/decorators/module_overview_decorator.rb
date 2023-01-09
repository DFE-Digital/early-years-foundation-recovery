class ModuleOverviewDecorator < DelegateClass(ModuleProgress)
  # @yield [Symbol, ModuleItem] state locales key and target page
  def call_to_action
    if completed?
      yield(:completed, mod.certificate_page)
    elsif failed_attempt?
      # via AssessmentResultsController#new to archive attempt
      yield(:failed, mod.assessment_intro_page)
    elsif started?
      yield(:started, resume_page)
    else
      yield(:not_started, mod.interruption_page)
    end
  end

  # @return [Array<String, Symbol, Array>]
  def sections
    mod.items_by_submodule.each.with_index(1).map do |(num, items), position|
      intro = items.first
      heading = num.nil? ? 'Module introduction' : intro.model.heading
      icon = status(items)
      topics = topics(submodule: num, items: items)
      [
        heading,                              # submodule intro heading
        position,                             # position
        icon,                                 # icon style
        topics,                               # Array(String, Symbol)
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

private


  # exclude intro or subpages
  #
  # @return [Array<String, Symbol, Array>]
  #
  # @param submodule [String]
  # @param items [Array<ModuleItems]
  def topics(submodule:, items:)
    items[1..].select(&:topic?).map do |topic|
      section_content(submodule: submodule, topic_item: topic)
    end
  end

  # @param submodule [String]
  # @param topic_item [ModuleItem]
  #
  # @return [Array<Array>]
  def section_content(submodule:, topic_item:)
    topic_status = status(topic_item.current_submodule_topic_items)

    # providing the next page name enables the hyperlink
    if clickable?(topic_item: topic_item, submodule: submodule)
      furthest_topic_page_name = topic_status.eql?(:started) ? resume_page : topic_item
    end

    # SummativeAssessmentProgress conditional pass
    if failed_attempt?
      topic_status = :failed if topic_item.assessment_intro?
      furthest_topic_page_name = nil if topic_item.confidence_intro?
    elsif successful_attempt?
      topic_status = :completed if topic_item.assessment_intro?
      furthest_topic_page_name = topic_item if topic_item.confidence_intro?
    end

    [
      topic_item.training_module,   # TrainingModule [mod]
      topic_item.model.heading,     # String (content page heading) [topic_heading]
      furthest_topic_page_name,     # String/nil (module_item name) [next_item]
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

    # if current_topic && previous_submodule
    #   all?(current_topic_items) && all?(previous_submodule_items)
    if current_topic
      all?(current_topic_items)
    else
      all?([topic_item])
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
end
