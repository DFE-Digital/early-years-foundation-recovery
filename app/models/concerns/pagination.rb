module Pagination

  # @return [Boolean]
  def page_numbers?
    case page_type
    when /intro|thankyou/ then false
    else
      true
    end
  end

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

  # @return [Integer] (zero index)
  def position_within_module
    parent.pages.rindex { |entry| entry.id.eql?(id) }
  end

  # @return [Integer] (zero index)
  def position_within_submodule
    current_submodule_items.index(self)
  end

  # @return [Integer] (zero index)
  def position_within_topic
    current_submodule_topic_items.index(self)
  end

  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def current_submodule_items
    parent.content_by_submodule.fetch(submodule)
  end

  # TODO: duplicated in overview decroator #fetch_submodule_topic
  #
  # @return [Array<Training::Page, Training::Video, Training::Question>]
  def current_submodule_topic_items
    parent.content_by_submodule_topic.fetch([submodule, topic])
  end

  # @return [Integer]
  def number_within_submodule
    if module_intro?
      0
    else
      current_submodule_items.count - 1
    end
  end

  # @return [Integer]
  def number_within_topic
    current_submodule_topic_items.count
  end

end
