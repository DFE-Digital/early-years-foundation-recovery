# TODO: assessments controller #new can be removed
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
  # @!attribute [r] assessment
  #   @return [AssessmentProgress]
  option :assessment, required: true

  # @return [String]
  def name
    previous_content = content.previous_item

    if skippable_page?
      previous_content.previous_item.name
    elsif skip_back_to_feedback_intro?
      mod.opinion_intro_page.name
    else
      content.previous_item.name
    end
  end

  # @return [String]
  def style
    if content.section? && !content.opinion_intro?
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

  # @return [Boolean]
  def disable_question_submission?
    if content.formative_question?
      answered?
    elsif content.summative_question?
      answered? && (Rails.application.migrated_answers? ? assessment.graded? : assessment.score.present?)
    else
      false
    end
  end

private

  # @return [Hash=>Symbol]
  def label
    I18n.t(:previous_page)
  end

  # @return [Boolean]
  def previous?
    content.interruption_page? || disable_question_submission?
  end

  # @return [Boolean]
  def answered?
    user.response_for(content).responded?
  end

  # @return [Boolean]
  def opinion_intro?
    content.opinion_intro?
  end

  # @return [Boolean]
  def content_section?
    content.section? && !content.opinion_intro?
  end

  # @return [Boolean]
  def skippable_page?
    !content.interruption_page? && content.previous_item.skippable? && user.response_for_shared(content.previous_item, mod).responded?
  end

  # @return [Boolean]
  def skip_back_to_feedback_intro?
    content.thankyou? && !user.response_for_shared(content.previous_item, mod).responded?
  end
end
