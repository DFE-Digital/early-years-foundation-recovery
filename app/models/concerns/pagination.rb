module Pagination # Progress / section / navigation

  # BOOLEAN --------------------------------------------------------------------

  # @return [Boolean]
  def content?
    !submodule_intro?
  end

  # @return [Boolean]
  def section?
    submodule_intro? || summary_intro?
  end

  # @return [Boolean]
  def subsection?
    topic_intro? || recap_page? || assessment_intro? || confidence_intro? || certificate?
  end

  # @return [Boolean]
  def page_numbers?
    case page_type
    when /intro|thankyou/ then false
    else
      true
    end
  end

  # BOOLEAN --------------------------------------------------------------------

  # @return [Hash{Symbol => nil, Integer}]
  def pagination
    { current: position_within_submodule, total: number_within_submodule }
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
    parent.pages[position_within_module - 1].id
  end

  # @return [String, nil]
  def next_item_id
    parent.pages[position_within_module + 1]&.id
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

  # @return [Integer] (zero index)
  def position_within_module  # position
    parent.pages.rindex(self)
  end

  # @return [Integer] (zero index)
  def position_within_submodule # section_position
    section_content.index(self)
  end

  # @return [Integer] (zero index)
  def position_within_topic # subsection_position
    subsection_content.index(self)
  end

  # @return [Integer]
  def number_within_submodule # section_size
    return 0 if module_intro?

    section_content.count(&:content?)
  end

  # @return [Integer]
  def number_within_topic # subsection_size
    subsection_content.count
  end
end
