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
  option :mod, Types.Instance(Training::Module), required: true

  # @see Training::ResponsesController#redirect
  #
  # @return [Array<UserAnswer>, Assessment, nil]
  def grade!
    if Rails.application.migrated_answers?
      unless graded?
        assessment.update(
          score: score,
          passed: passed?,
          completed_at: Time.zone.now,
        )
      end
    else
      update_responses(user_assessment_id: assessment.id)
    end
  end

  # @see Training::AssessmentsController#new
  #
  # @return [Array<UserAnswer>] deprecate
  def retake!
    if Rails.application.migrated_answers?
      :no_op
    else
      update_responses(archived: true)
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
    if Rails.application.migrated_answers?
      assessment&.passed? || score >= THRESHOLD
    else
      score >= THRESHOLD
    end
  end

  # @return [Boolean]
  def failed?
    !passed?
  end

  # deprecate see track_events
  # @return [Boolean] CTA failed_attempt state
  def attempted?
    if Rails.application.migrated_answers?
      assessment.present?
    else
      user.user_assessments.where(assessments_type: 'summative_assessment', module: mod.name).any?
    end
  end

  # @return [Float] percentage of correct responses
  def score
    if Rails.application.migrated_answers?
      assessment.score || (correct_responses.count.to_f / mod.summative_questions.count) * 100
    else
      (correct_responses.count.to_f / mod.summative_questions.count) * 100
    end
  rescue ZeroDivisionError, NoMethodError
    0.0
  end

  # @return [Array<Response>]
  def incorrect_responses
    assessment_responses.reject(&:correct?)
  end

  # delegate :responses, to: :assessment # swap to delegation
  # @return [Array<Response>, Array<UserAnswers>]
  def assessment_responses
    if Rails.application.migrated_answers?
      assessment.responses
    else
      user.user_answers
        .not_archived.where(module: mod.name)
        .select { |response| response.question.summative_question? }
    end
  end

  # @return [Array<UserAnswer>] deprecate
  def update_responses(params)
    assessment_responses.each { |response| response.update!(params) }
  end

  # @note #correct? validates against current question options
  # @return [Array<Response>]
  def correct_responses
    assessment_responses.select(&:correct?)
  end

  # @return [UserAssessment, Assessment] drop memoisation
  def assessment
    @assessment ||= if Rails.application.migrated_answers?
                      user.assessments.where(training_module: mod.name).order(:started_at).last
                    else
                      UserAssessment.create!(
                        user_id: user.id,
                        score: score.to_i,
                        status: status,
                        module: mod.name,
                        assessments_type: 'summative_assessment',
                      )
                    end
  end
end
