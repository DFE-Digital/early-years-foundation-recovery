# TODO: assessments controller #new can be removed
#
# Button or link labels to the next page
# @see [LinkHelper#link_to_next]
#
class NextPageDecorator
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
  # @!attribute [r] assessment
  #   @return [AssessmentProgress]
  option :assessment

  # @return [String]
  def name
    if content.interruption_page?
      mod.content_start.name
    elsif skip_next_question?
      next_next_item.name
    else
      next_item.name
    end
  end

  # @see [Pagination]
  # @return [String]
  def text
    case
    when next?             then label[:next]
    when missing?          then label[:missing]
    when content_section?  then label[:section]
    when confidence_outro? then label[:give_feedback]
    when test_start?       then label[:start_test]
    when test_finish?      then label[:finish_test]
    when finish?           then label[:finish]
    when save?             then label[:save_continue]
    else
      label[:next]
    end
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
    I18n.t(:next_page)
  end

  # @return [Boolean]
  def next?
    content.interruption_page? || disable_question_submission?
  end

  # @return [Boolean]
  def save?
    content.notes? || content.summative_question?
  end

  # @return [Boolean]
  def answered?
    user.response_for(content).responded?
  end

  # @return [Boolean]
  def finish?
    next_item.certificate?
  end

  # @return [Boolean]
  def test_start?
    content.next_item.summative_question? &&
      !content.summative_question? &&
      !disable_question_submission?
  end

  # @return [Boolean]
  def test_finish?
    next_item.assessment_results? && !disable_question_submission?
  end

  # @return [Boolean]
  def missing?
    next_item.eql?(content) && wip?
  end

  # @return [Boolean]
  def confidence_outro?
    mod.feedback_questions.first.previous_item.eql?(content)
  end

  # @return [Boolean]
  def content_section?
    content.section? && !content.feedback_question?
  end

  # @return [Boolean]
  def wip?
    Rails.application.preview? || Rails.env.test?
  end

  # @note only used if a skippable question follows a non-question
  # @return [Boolean]
  def skip_next_question?
    user.skip_question?(next_item)
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def next_next_item
    content.with_parent(mod).next_next_item
  end

  # @return [Training::Page, Training::Question, Training::Video]
  def next_item
    content.with_parent(mod).next_item
  end
end
