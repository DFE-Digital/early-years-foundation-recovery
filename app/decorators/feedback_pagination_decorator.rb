class FeedbackPaginationDecorator < PaginationDecorator
  # TODO: Add type check for feedback question type
  # @!attribute [r] content
  #   @return [Training::Question]
  # param :content, Types::TrainingContent, required: true

  # @return [String]
  def heading
    'Additional feedback'
  end

  # @return [String]
  # def section_numbers
  #   I18n.t(:section, scope: :pagination, current: content.submodule - 1, total: section_total - 1)
  # end

  # private

  # @return [Integer]
  # def page_total
  #   size = content.section_content.size
  #   if content.section_content.any?(&:skippable?) # && response_for_shared.responded?
  #     # don't count skipped page
  #     content.section_content.each do |section_content|
  #       if section_content.feedback_question? && section_content.skippable_question.eql?(false)
  #         size -= 1
  #       end
  #     end
  #   end

  #   size
  # end
end
