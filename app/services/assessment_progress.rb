# Summative assessment evaluation
#
class AssessmentProgress
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true

  # @see Training::ResponsesController#redirect
  #
  # @return [Array<UserAnswer, Response>]
  def complete!
    update_responses(user_assessment_id: user_assessment.id)
  end

  # @see Training::AssessmentsController#new
  #
  # @return [Array<UserAnswer, Response>]
  def archive!
    update_responses(archived: true)
  end

  # @see ContentHelper#results_banner
  #
  # @return [Hash]
  def result
    { success: passed?, score: score.to_i }
  end

  # @return [Symbol]
  def status
    passed? ? :passed : :failed
  end

  # @return [Boolean]
  def passed?
    score >= mod.summative_threshold
  end

  # @return [Boolean]
  def failed?
    !passed?
  end

  # TODO: assessments_type is a useless field and should be removed
  #
  # @return [Boolean] CTA failed_attempt state
  def attempted?
    user.user_assessments.where(assessments_type: 'summative_assessment', module: mod.name).any?
  end

  # @return [Float] percentage of correct responses
  def score
    (correct_responses.count.to_f / mod.summative_questions.count) * 100
  rescue ZeroDivisionError
    0.0
  end

  # @return [Array<Response>]
  def incorrect_responses
    assessment_responses.reject(&:correct?)
  end

private

  # @return [Array<Response>, Array<UserAnswers>]
  def assessment_responses
    if ENV['DISABLE_USER_ANSWER'].present?
      user.responses
        .unarchived.where(training_module: mod.name)
        .select { |response| response.question.summative_question? }
    else
      user.user_answers
        .not_archived.where(module: mod.name)
        .select { |response| response.question.summative_question? }
    end
  end

  # @return [Array<UserAnswer, Response>]
  def update_responses(params)
    assessment_responses.each { |response| response.update!(params) }
  end

  # @note #correct? uses answers validate against question
  # @return [Array<Response>]
  def correct_responses
    assessment_responses.select(&:correct?)
  end

  # @return [UserAssessment]
  def user_assessment
    @user_assessment ||= UserAssessment.create!(
      user_id: user.id,
      score: score.to_i,
      status: status,
      module: mod.name,
      assessments_type: 'summative_assessment',
    )
  end
end