# Content in sections, navigation
#
module Pagination
  # BOOLEAN --------------------------------------------------------------------

  # @return [Boolean]
  def section?
    submodule_intro? || summary_intro?
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

  # BOOLEAN --------------------------------------------------------------------

  # @return [Hash{Symbol => Integer}]
  def pagination
    { current: section_content.index(self), total: section_size }
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

  # @return [String]
  def previous_item_id
    parent.pages[content_index - 1].id
  end

  # @return [String, nil]
  def next_item_id
    parent.pages[content_index + 1]&.id
  end

  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def section_content
    parent.content_by_submodule.fetch(submodule)
  end

  # TODO: duplicated in overview decroator #fetch_submodule_topic
  #
  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def subsection_content
    parent.content_by_submodule_topic.fetch([submodule, topic])
  end

  # INTEGER --------------------------------------------------------------------

  # @return [nil, Integer]
  def submodule
    return if interruption_page?

    submodule, _entries = parent.content_by_submodule.find { |_, values| values.include?(self) }
    submodule
  end

  # @return [nil, Integer]
  def topic
    return if interruption_page?

    (_submodule, topic), _entries = parent.content_by_submodule_topic.find { |_, values| values.include?(self) }
    topic
  end

  # @return [Integer]
  def section_size
    return 0 if module_intro?

    section_content.count { |c| !c.submodule_intro? }
  end

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

  # @return [Integer]
  def content_index
    parent.pages.rindex(self)
  end
end
