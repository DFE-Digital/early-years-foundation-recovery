# Module content sections and subsections
# Call to action button logic
#
class ModuleOverviewDecorator < DelegateClass(ModuleProgress)
  # @see LearningController#module_progress
  # @return [String]
  def description
    if unvisited.size <= 20
      I18n.t('my_learning.progress.remaining', num: unvisited.size)
    else
      I18n.t('my_learning.progress.viewed', num: visited.size)
    end
  end

  # @see LearningController#module_progress
  # @return [String]
  def percentage
    "#{(value * 100).round}%"
  end

  # @return [Array<Symbol, <Training::Page, Training::Question, Training::Video>?] state locales key and target page
  def call_to_action
    if completed?
      [:completed, mod.certificate_page]
    elsif failed_attempt?
      # via AssessmentsController#new to archive attempt
      [:failed, mod.assessment_intro_page]
    elsif started?
      [:started, resume_page]
    else
      [:not_started, mod.interruption_page]
    end
  end

  def sections
    mod.content_sections.each_with_index.map do |(submodule, content_items), idx|
      first_item = content_items.first
      position = first_item.certificate? ? idx : (idx + 1)

      {
        heading: heading(first_item),
        page_count: page_count(content_items),
        position: position,
        display_line: (idx + 1) != mod.submodule_count,
        icon: status(content_items),
        subsections: subsections(submodule: submodule, items: content_items),
        hide: first_item.feedback_question?,
      }
    end
  end

  def section_heading(heading, section_page_count, include_page_count: false)
    if include_page_count
      heading + "<span class='greyed-out'>  (#{section_page_count} pages)</span>"
    else
      heading
    end
  end

  # Check every item has been visited (public for debugging).
  # Presence of 'module_complete' bypasses individual checks.
  #
  # @param items [Array<Training::Page, Training::Question, Training::Video>]
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
    mod.content_subsections.map { |(submodule, topic), items|
      <<~NODE
        #{submodule}.#{topic}: #{status(items)}
      NODE
    }.join
  end

private

  # @param page [Training::Page, Training::Question, Training::Video]
  # @return [String]
  def heading(page)
    page.certificate? ? 'Complete module' : page.heading
  end

  # @param pages [Array<Training::Page, Training::Question, Training::Video>]
  # @return [String]
  def page_count(pages)
    I18n.t('my_learning.page_count', num: pages.size) unless pages.one?
  end

  # @param submodule [Integer]
  # @param items [Array<Training::Page, Training::Question, Training::Video>]
  #
  # @return [Array<String, Symbol, Array>]
  def subsections(submodule:, items:)
    items.select(&:subsection?).map do |content_page|
      section_content(submodule: submodule, subsection_item: content_page)
    end
  end

  # @param submodule [Integer]
  # @param subsection_item [Training::Page, Training::Question, Training::Video]
  #
  # @return [Array<Array>]
  def section_content(submodule:, subsection_item:)
    subsection_status = if submodule.zero?
                          status([subsection_item])
                        else
                          status(subsection_item.subsection_content)
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
  # @param subsection_item [Training::Page, Training::Question, Training::Video]
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
  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def fetch_submodule(submodule)
    mod.content_sections.fetch(submodule)
  end

  # @param submodule [Integer]
  # @param topic [Integer]
  # @return [Array<Training::Page, Training::Question, Training::Video>]
  def fetch_submodule_topic(submodule, topic)
    mod.content_subsections.fetch([submodule, topic])
  end
end
