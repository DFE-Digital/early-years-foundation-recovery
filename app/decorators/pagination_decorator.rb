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
    content.section_content.first.heading
  end

  # @return [String]
  def section_numbers
    if content.opinion_intro? || content.feedback_question?
      I18n.t(:section, scope: :pagination, current: content.submodule - 1, total: section_total - 1)
    else
      I18n.t(:section, scope: :pagination, current: content.submodule, total: section_total - 1)
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
    size = content.section_content.size
    if content.section_content.any?(&:skippable?) # && response_for_shared.responded?
      # don't count skipped page
      content.section_content.each do |section_content|
        if section_content.feedback_question? && section_content.always_show_question.eql?(false)
          size -= 1
        end
      end
    end

    size
  end

  # @return [Integer]
  def section_total
    content.parent.content_sections.size
  end
end
