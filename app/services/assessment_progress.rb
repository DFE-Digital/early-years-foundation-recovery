# Assessment grading
#
# An assessment is created when the first summative question is answered?
class AssessmentProgress
  extend Dry::Initializer

  # @return [Float]
  THRESHOLD = 70.0

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types::TrainingModule, required: true

  # Idempotent: grades the current attempt once, then does nothing.
  #
  # @see Training::ResponsesController#redirect
  # @see Training::AssessmentsController#show
  #
  # @return [Assessment, nil]
  def grade!
    return if assessment.nil? || graded?

    report_duplicates
    assessment.update(
      score: score,
      passed: passed?,
      completed_at: Time.zone.now,
    )
  end

  # @return [Boolean] every current summative question has a response
  def complete?
    return false if assessment.nil?

    answered = assessment.responses.pluck(:question_name)
    mod.summative_questions.all? { |question| answered.include?(question.name) }
  end

  # @see ContentHelper#assessment_banner
  # @return [Symbol] I18n key
  def status
    passed? ? :pass : :fail
  end

  # @return [Boolean, nil]
  delegate :graded?, to: :assessment, allow_nil: true

  # @return [Boolean]
  def passed?
    assessment&.passed? || score >= THRESHOLD
  end

  # @return [Boolean]
  def failed?
    !passed?
  end

  # @return [Boolean] CTA failed_attempt state
  def attempted?
    assessment.present?
  end

  # @return [Float] percentage of correct responses
  def score
    existing_score = assessment&.score
    return existing_score if existing_score.present?

    total_questions = mod.summative_questions.count

    if total_questions.zero?
      Rails.logger.error "Zero Percent progress logged user_id=#{user&.id} mod=#{mod&.name}"
      return 0.0
    end

    (correct_responses.count.to_f / total_questions) * 100
  rescue StandardError => e
    Rails.logger.error "AssessmentProgress.score error user_id=#{user&.id} mod=#{mod&.name}: #{e.class}: #{e.message}"
    0.0
  end

  # @note #correct? validates against current question options
  # @return [Array<Response>] safe accessor; empty when no assessment exists
  def assessment_responses
    assessment&.responses || []
  end

  # @return [Array<Response>]
  def incorrect_responses
    assessment_responses.reject(&:correct?)
  end

  # @return [Array<Response>]
  def correct_responses
    assessment_responses.select(&:correct?)
  end

  # @return [Assessment]
  def assessment
    @assessment ||= user.current_assessment(mod.name)
  end

private

  # Stray incomplete attempts are harmless but tracked to measure frequency
  # @return [void]
  def report_duplicates
    others = user.assessments.incomplete.where(training_module: mod.name).where.not(id: assessment.id).pluck(:id)
    return if others.empty?

    message = "Duplicate incomplete assessments user_id=#{user.id} mod=#{mod.name} graded=#{assessment.id} others=#{others.join(',')}"
    Rails.logger.warn(message)
    Sentry.capture_message(message, level: :warning)
  end
end
