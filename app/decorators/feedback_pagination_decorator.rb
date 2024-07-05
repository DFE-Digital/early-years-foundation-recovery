# Overrides heading
# Checks if one-off questions should be skipped
#
class FeedbackPaginationDecorator < PaginationDecorator
  # TODO: Add type check for feedback question type

  # @!attribute [r] user
  #   @return [User]
  param :user, Types.Instance(User), required: true

  # @return [String]
  def heading
    'Additional feedback'
  end

private

  # @return [Integer]
  def current_page
    return super unless skip_question? && after_skippable_question?

    super - 1
  end

  # @return [Integer]
  def page_total
    return super unless skip_question?

    super - 1
  end

  # @return [Boolean]
  def after_skippable_question?
    content.section_content.index(content) > content.section_content.index(skippable_question)
  end

  # @return [Training::Question]
  def skippable_question
    content.section_content.find(&:skippable?)
  end

  # @return [Array<Training::Module, Course>]
  def other_forms
    Training::Module.live.to_a - [content.parent] << Course.config
  end

  # @return [Boolean]
  def skip_question?
    other_forms.any? do |form|
      user.response_for_shared(skippable_question, form).responded?
    end
  end
end
