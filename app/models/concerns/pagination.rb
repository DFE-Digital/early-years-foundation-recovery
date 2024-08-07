# Content in sections, navigation
#
module Pagination
  # @return [Boolean]
  def section?
    submodule_intro? || summary_intro? || feedback_intro? || certificate?
  end

  # @return [Boolean]
  def subsection?
    topic_intro? || recap_page? || assessment_intro? || confidence_intro? || certificate?
  end

  # @see app/views/training/pages/text_page.html.slim
  #
  # @return [Boolean]
  def page_numbers?
    topic_intro? || text_page?
  end

  # @return [nil, Training::Page, Training::Video, Training::Question]
  def previous_item
    return if interruption_page?

    parent.page_by_id(previous_item_id)
  end

  # @note Whilst being authored, reload if the next page is yet to be created
  #
  # @return [Training::Page, Training::Video, Training::Question]
  def next_item
    parent.page_by_id(next_item_id) || self
  end

  # @return [nil, Training::Page, Training::Video, Training::Question]
  def next_next_item
    parent.page_by_id(next_next_item_id)
  end

  # @return [nil, Training::Page, Training::Video, Training::Question]
  def previous_previous_item
    parent.page_by_id(previous_previous_item_id)
  end

  # @return [String]
  def previous_item_id
    parent.pages[content_index - 1].id
  end

  # @return [String, nil]
  def previous_previous_item_id
    parent.pages[content_index - 2]&.id
  end

  # @return [String, nil]
  def next_item_id
    parent.pages[content_index + 1]&.id
  end

  # @return [String, nil]
  def next_next_item_id
    parent.pages[content_index + 2]&.id
  end

  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def section_content
    if parent.is_a? Training::Module # OPTIMIZE: introduce parent check predicates?
      parent.content_sections.fetch(submodule)
    else
      Course.config.pages
    end
  end

  # TODO: duplicated in overview decorator #fetch_submodule_topic
  #
  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def subsection_content
    if parent.is_a? Training::Module
      parent.content_subsections.fetch([submodule, topic])
    else
      Course.config.pages
    end
  end

  # @return [nil, Integer]
  def submodule
    return if interruption_page?

    submodule, _entries = parent.content_sections.find { |_, values| values.include?(self) }
    submodule
  end

  # @return [nil, Integer]
  def topic
    return if interruption_page?

    (_submodule, topic), _entries = parent.content_subsections.find { |_, values| values.include?(self) }
    topic
  end

  # @see #debug_summary
  # @return [Integer]
  def section_size
    section_content.count { |c| !c.submodule_intro? }
  end

  # @see #debug_summary
  # @return [Integer]
  def subsection_size
    subsection_content.count
  end

  # @see #debug_summary
  # @param collection [Array<Training::Page, Training::Video, Training::Question>]
  # @return [String]
  def position_within(collection)
    (collection.index(self) + 1).ordinalize
  end

private

  # @return [Boolean]
  def feedback_intro?
    feedback_question? && first_feedback?
  end

  # @return [Integer]
  def content_index
    parent.pages.rindex(self)
  end
end
