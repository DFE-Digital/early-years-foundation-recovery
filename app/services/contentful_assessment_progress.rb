# Summative assessment evaluation
#
class ContentfulAssessmentProgress
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true

  def save!
    user_assessment = create_user_assessment

    if assessment_responses.all?(&:persisted?) && user_assessment.persisted?
      assessment_responses.each do |response|
        response.update(user_assessment_id: user_assessment.id)
      end
    end
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

  # @return [Array<UserAnswer, Response>]
  def archive
    assessment_responses.each do |response|
      response.update!(archived: true)
    end
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

  # @note #correct? uses answers validate against question
  # @return [Array<Response>]
  def correct_responses
    assessment_responses.select(&:correct?)
  end

  # @return [UserAssessment]
  def create_user_assessment
    UserAssessment.create!(
      user_id: user.id,
      score: score.to_i,
      status: status,
      module: mod.name,
      assessments_type: 'summative_assessment',
    )
  end
end
