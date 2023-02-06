class ContentfulModuleOverviewDecorator < DelegateClass(ContentfulModuleProgress)
  # @yield [Symbol, Module::Content] state locales key and target page
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
    mod.content_by_submodule.each.with_index(1).map do |(submodule, content_items), position|
      {
        heading: submodule.zero? ? 'Module introduction' : content_items.first.heading,
        position: position,
        display_line: position != mod.submodule_count,
        icon: status(content_items),
        subsections: subsections(submodule: submodule, items: content_items),
      }
    end
  end

  # Check every item has been visited (public for debugging)
  #
  # @param items [Array<Module::Content>]
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
  # @param submodule [Integer]
  # @param items [Array<Module::Content>]
  #
  # @return [Array<String, Symbol, Array>]
  def subsections(submodule:, items:)

    # binding.pry


    items_without_submodule_intro = submodule.zero? ? items : items.drop(1)

    # @see content_by_submodule and content_by_topic
    topics = items_without_submodule_intro.select { |page| page.topic.positive? }

    topics.map do |content_page|
      section_content(submodule: submodule, subsection_item: content_page)
    end


    # items_without_submodule_intro = submodule.zero? ? items : items.drop(1)

    # items_without_submodule_intro.select(&:topic?).map do |subsection|
    #   section_content(submodule: submodule, subsection_item: subsection)
    # end
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
      mod: subsection_item.parent,
      heading: subsection_item.model.heading,
      next_item: furthest_topic_page_name,
      status: subsection_status,
    }
  end

  # @param submodule [Integer]
  # @param subsection_item [Module::Content]
  #
  # @return [Boolean]
  def clickable?(submodule:, subsection_item:)
    # intros are being removed
    # return all?([subsection_item]) if submodule.zero?

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
