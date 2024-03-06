#
# Button or link labels to the previous page
# @see [LinkHelper#link_to_previous]
#
class PreviousPageDecorator
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types::TrainingModule, required: true
  # @!attribute [r] content
  #   @return [Training::Page, Training::Question, Training::Video]
  option :content, Types::TrainingContent, required: true

  # @return [String]
  def name
    if skip_previous_question?
      content.previous_item.previous_item.name
    elsif feedback_not_started?
      mod.feedback_questions.first.previous_item.name # OPTIMIZE: doubtful a specific type is even necessary
    else
      content.previous_item.name
    end
  end

  # @return [String]
  def style
    if content.section? && !content.first_feedback?
      'section-intro-previous-button'
    else
      'govuk-button--secondary'
    end
  end

  # @see [Pagination]
  # @return [String]
  def text
    label[:previous]
  end

private

  # @return [Hash=>Symbol]
  def label
    I18n.t(:previous_page)
  end

  # @return [Boolean]
  def answered?(question)
    return false unless question.feedback_question?

    user.response_for_shared(question, mod).responded?
  end

  # @return [Boolean]
  def content_section?
    content.section? && !content.first_feedback?
  end

  # @return [Boolean]
  def skip_previous_question?
    content.previous_item.skippable? && answered?(content.previous_item)
  end

  # on the post-feedback page with the last feedback question unanswered
  #
  #   - once a feedback question is answered the feedback form is started
  #   - a response for the last question is therefore sufficient to determine this
  #   - because you can't get here without answering the last question
  #
  # @return [Boolean]
  def feedback_not_started?
    content.thankyou? && !answered?(content.previous_item)
  end
end
