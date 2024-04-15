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

  # @param question [Training::Question]
  # @return [Boolean]
  def skip_question?(question)
    question.skippable? && response_for_shared(question).responded?
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

private

  # @return [Response::ActiveRecord_Relation]
  def responses
    Response.course_feedback.where(visit_id: visit.id)
  end
end
