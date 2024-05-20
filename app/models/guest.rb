#
# Fallback "current_user" object for visitor feedback forms
#
class Guest < Dry::Struct
  # @!attribute [r] visit
  #   @return [Visit]
  attribute :visit, Types.Instance(Visit)

  # @return [String]
  delegate :visit_token, to: :visit

  # @return [Boolean]
  def guest?
    true
  end

  # @return [Boolean]
  def course_started?
    false
  end

  # @param question [Training::Question]
  # @return [Boolean]
  def skip_question?(question)
    question.skippable? || question.name.eql?('prevent-from-completing-training')
  end

  # @param content [Training::Question] feedback questions
  # @param mod [Course]
  # @return [Response]
  def response_for_shared(content, mod = Course.config)
    responses.find_or_initialize_by(
      question_type: content.page_type,
      question_name: content.name,
      training_module: mod.name,
      visit_id: visit.id,
    )
  end

  # @return [Boolean]
  def completed_course_feedback?
    guest_questions.count.eql?(responses.count)
  end

private

  # @return [Array<Training::Question>]
  def guest_questions
    Course.config.feedback_questions.reject { |question| skip_question?(question) }
  end

  # @return [Response::ActiveRecord_Relation]
  def responses
    Response.course_feedback.where(visit_id: visit.id)
  end
end
