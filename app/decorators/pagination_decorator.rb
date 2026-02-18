#
# Position within the current module section
#
class PaginationDecorator
  extend Dry::Initializer

  # @!attribute [r] content
  #   @return [Training::Page, Training::Question, Training::Video]
  param :content, Types::TrainingContent, required: true

  # @return [String]
  def heading
    return I18n.t('summary_intro.heading') if content.thankyou?

    content.section_content.first.heading
  end

  # @return [String]
  def section_numbers
    # Only show section index for visible sections
    if content.pre_confidence_question? || content.pre_confidence_intro?
      nil
    else
      # Find visible section index
      visible_sections = content.parent.content_sections.select do |_, content_items|
        first_item = content_items.first
        !first_item.pre_confidence_question? && !first_item.pre_confidence_intro?
      end
      index = visible_sections.find_index { |_, items| items.include?(content) }&.then { |i| i + 1 }
      I18n.t(:section, scope: :pagination, current: index, total: section_total) if index
    end
  end

  # @return [String]
  def page_numbers
    I18n.t(:page, scope: :pagination, current: current_page, total: page_total)
  end

  # @return [String]
  def percentage
    "#{(current_page.to_f / page_total * 100).round}%"
  end

private

  # @return [Integer]
  def current_page
    content.section_content.index(content) + 1
  end

  # @return [Integer]
  def page_total
    content.section_content.size
  end

  # @return [Integer]
  def section_total
    content.parent.content_sections.count do |(_, content_items)|
      first_item = content_items.first
      !first_item.feedback_question? && !first_item.pre_confidence_question? && !first_item.pre_confidence_intro?
    end
  end
end
