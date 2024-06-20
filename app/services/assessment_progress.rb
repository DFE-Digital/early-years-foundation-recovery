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

  # @see Training::ResponsesController#redirect
  #
  # @return [Assessment, nil]
  def grade!
    unless graded?
      assessment.update(
        score: score,
        passed: passed?,
        completed_at: Time.zone.now,
      )
    end
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

  # deprecate see track_events
  # @return [Boolean] CTA failed_attempt state
  def attempted?
    assessment.present?
  end

  # @return [Float] percentage of correct responses
  def score
    assessment.score || (correct_responses.count.to_f / mod.summative_questions.count) * 100
  rescue ZeroDivisionError, NoMethodError
    0.0
  end

  # @note #correct? validates against current question options
  # @return [Array<Response>]
  delegate :responses, to: :assessment, prefix: true

  # @return [Array<Response>]
  def incorrect_responses
    assessment_responses.reject(&:correct?)
  end

  # @return [Array<Response>]
  def correct_responses
    assessment_responses.select(&:correct?)
  end

  # TODO: drop memoisation
  # @return [Assessment]
  def assessment
    @assessment ||= user.assessments.where(training_module: mod.name).order(:started_at).last
  end
end
