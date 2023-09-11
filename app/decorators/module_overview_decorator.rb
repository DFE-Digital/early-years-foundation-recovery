class ModuleOverviewDecorator < DelegateClass(ModuleProgress)
  # @yield [Symbol, Module::Content] state locales key and target page
  def call_to_action
    if completed?
      yield(:completed, mod.certificate_page)
    elsif failed_attempt?
      # via AssessmentsController#new to archive attempt
      yield(:failed, mod.assessment_intro_page)
    elsif started?
      yield(:started, resume_page)
    else
      yield(:not_started, mod.interruption_page)
    end
  end

  # @return [Hash{Symbol => Mixed}]
  def sections
    mod.content_by_submodule.each.with_index(1).map do |(submodule, content_items), position|
      {
        heading: section_heading(content_items.first.heading, content_items.size, position != mod.submodule_count).html_safe, 
        position: position,
        display_line: position != mod.submodule_count,
        icon: status(content_items),
        subsections: subsections(submodule: submodule, items: content_items),
      }
    end
  end

  def section_heading(heading, section_page_count, include_page_count = false)
    if include_page_count 
      heading + "<span class='greyed-out'>  (#{section_page_count} pages)</span>"
    else 
      heading
    end
  end

  # Check every item has been visited (public for debugging).
  # Presence of 'module_complete' bypasses individual checks.
  #
  # @param items [Array<Module::Content>]
  # @return [Symbol]
  def status(items)
    if completed? || all?(items)
      :completed
    elsif any?(items)
      :started
    elsif none?(items)
      :not_started
    else
      :unknown
    end
  end

  # @return [String]
  def debug_summary
    mod.content_by_submodule_topic.map { |(submodule, topic), items|
      <<~NODE
        #{submodule}.#{topic}: #{status(items)}
      NODE
    }.join
  end

private

  # exclude intro or subpages
  #
  # @param submodule [Integer]
  # @param items [Array<Module::Content>]
  #
  # @return [Array<String, Symbol, Array>]
  def subsections(submodule:, items:)
    topics =
      if submodule.zero?
        items
      else
        items.drop(1).reject(&:topic_page_name?)
      end

    topics.map do |content_page|
      section_content(submodule: submodule, subsection_item: content_page)
    end
  end

  # @param submodule [Integer]
  # @param subsection_item [Module::Content]
  #
  # @return [Array<Array>]
  def section_content(submodule:, subsection_item:)
    subsection_status = if submodule.zero?
                          status([subsection_item])
                        else
                          status(subsection_item.current_submodule_topic_items)
                        end

    # providing the next page name enables the hyperlink
    if clickable?(subsection_item: subsection_item, submodule: submodule)
      furthest_topic_page = subsection_status.eql?(:started) ? resume_page : subsection_item
    end

    # SummativeAssessmentProgress conditional pass
    if failed_attempt?
      subsection_status = :failed if subsection_item.assessment_intro?
      furthest_topic_page = nil if subsection_item.confidence_intro?
    elsif successful_attempt?
      subsection_status = :completed if subsection_item.assessment_intro?
      furthest_topic_page = subsection_item if subsection_item.confidence_intro?
    end

    {
      mod_name: subsection_item.parent.name,
      heading: subsection_item.heading,
      next_page_name: furthest_topic_page&.name,
      status: subsection_status,
    }
  end

  # @param submodule [Integer]
  # @param subsection_item [Module::Content]
  #
  # @return [Boolean]
  def clickable?(submodule:, subsection_item:)
    return all?([subsection_item]) if submodule.zero?

    submodule_intro = fetch_submodule(submodule).first
    return false unless visited?(submodule_intro)

    current_topic_items = fetch_submodule_topic(submodule, subsection_item.topic)
    all?(current_topic_items)
  end

  # @param submodule [Integer]
  # @return [Array<Training::Content>]
  def fetch_submodule(submodule)
    mod.content_by_submodule.fetch(submodule)
  end

  # @param submodule [Integer]
  # @param topic [Integer]
  # @return [Array<Training::Content>]
  def fetch_submodule_topic(submodule, topic)
    mod.content_by_submodule_topic.fetch([submodule, topic])
  end
end
