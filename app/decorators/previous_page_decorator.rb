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
    if skip_feedback_section?
      mod.feedback_questions.first.previous_item.name
    elsif skip_pre_confidence_section?
      mod.pre_confidence_questions.first.previous_item.name
    elsif skip_previous_question?
      previous_previous_item.name
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
  def skip_feedback_section?
    content.thankyou? && !answered?(previous_item)
  end

  # @return [Boolean]
  def skip_pre_confidence_section?
    content.submodule_intro? && !answered?(previous_item) && previous_item.pre_confidence_question?
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def previous_previous_item
    content.with_parent(mod).previous_previous_item
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def previous_item
    if ENV['DISABLE_PRE_CONFIDENCE_CHECK'] == 'true' && content.name == mod.content_start.name
      # Ensure correct page is shown in this scenario when previous button is clicked
      mod.interruption_page
    else
      content.with_parent(mod).previous_item
    end
  end
end
