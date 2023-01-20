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

  # @return [Hash{Symbol => Mixed}]
  def sections
    mod.items_by_submodule.each.with_index(1).map do |(num, items), position|
      {
        heading: num.nil? ? 'Module introduction' : items.first.model.heading,
        position: position,
        display_line: position != mod.items_by_submodule.size,
        icon: status(items),
        subsections: subsections(submodule: num, items: items),
      }
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
  # @param items [Array<ModuleItems>]
  def subsections(submodule:, items:)
    items_without_submodule_intro = submodule.nil? ? items : items.drop(1)

    items_without_submodule_intro.select(&:topic?).map do |subsection|
      section_content(submodule: submodule, subsection_item: subsection)
    end
  end

  # @param submodule [String]
  # @param subsection_item [ModuleItem]
  #
  # @return [Array<Array>]
  def section_content(submodule:, subsection_item:)
    subsection_status = if submodule.nil?
                          status([subsection_item])
                        else
                          status(subsection_item.current_submodule_topic_items)
                        end

    # providing the next page name enables the hyperlink
    if clickable?(subsection_item: subsection_item, submodule: submodule)
      furthest_topic_page_name = subsection_status.eql?(:started) ? resume_page : subsection_item
    end

    # SummativeAssessmentProgress conditional pass
    if failed_attempt?
      subsection_status = :failed if subsection_item.assessment_intro?
      furthest_topic_page_name = nil if subsection_item.confidence_intro?
    elsif successful_attempt?
      subsection_status = :completed if subsection_item.assessment_intro?
      furthest_topic_page_name = subsection_item if subsection_item.confidence_intro?
    end

    {
      mod: subsection_item.training_module,
      heading: subsection_item.model.heading,
      next_item: furthest_topic_page_name,
      status: subsection_status,
    }
  end

  # @param submodule [String]
  # @param subsection_item [ModuleItem]
  #
  # @return [Boolean]
  def clickable?(submodule:, subsection_item:)
    return all?([subsection_item]) if submodule.nil?

    submodule_intro = mod.module_items_by_submodule(submodule).first
    return false unless visited?(submodule_intro)

    current_topic = find_topic(subsection_item.topic_name, submodule)
    current_topic_items = current_topic.values.first.to_a

    all?(current_topic_items) if current_topic
  end

  # @param current_top_num [String]
  # @param current_sub_num [String]
  #
  # @return [Array<Array>] [1,2] [item, item, item]
  def find_topic(topic_num, submodule_num)
    mod.items_by_topic.select do |(match_sub_num, match_topic_num), _items|
      match_sub_num.eql?(submodule_num) && match_topic_num.eql?(topic_num)
    end
  end
end
