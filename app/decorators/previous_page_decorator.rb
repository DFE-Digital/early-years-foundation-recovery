#
# Button or link labels to the previous page
# @see [LinkHelper#link_to_previous]
#
class PreviousPageDecorator
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User, Guest]
  option :user, Types.Instance(User) | Types.Instance(Guest), required: true
  # @!attribute [r] mod
  #   @return [Course, Training::Module]
  option :mod, Types::Parent, required: true
  # @!attribute [r] content
  #   @return [Training::Page, Training::Question, Training::Video]
  option :content, Types::TrainingContent, required: true

  # @return [String]
  def name
    if skip_previous_question?
      previous_previous_item.name
    elsif feedback_not_started?
      mod.feedback_questions.first.previous_item.name
    else
      previous_item.name
    end
  end

  # @return [String]
  def style
    content_section? ? 'section-intro-previous-button' : 'govuk-button--secondary'
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
  def content_section?
    content.section? && !content.feedback_question?
  end

  # @return [Boolean]
  def skip_previous_question?
    user.skip_question?(previous_item)
  end

  # @return [Boolean]
  def answered?(question)
    return false unless question.feedback_question?

    user.response_for_shared(question, mod).responded?
  end

  # @return [Boolean]
  def feedback_not_started?
    content.thankyou? && !answered?(previous_item)
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def previous_previous_item
    content.with_parent(mod).previous_previous_item
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def previous_item
    content.with_parent(mod).previous_item
  end
end
