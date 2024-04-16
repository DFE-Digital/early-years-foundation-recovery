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
    I18n.t(:section, scope: :pagination, current: content.submodule, total: section_total)
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
    content.parent.content_sections.size
  end
end
