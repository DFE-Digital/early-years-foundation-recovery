# Confidence check
#
class ConfidenceCheckProgress
  # @param user [User]
  # @param mod [TrainingModule]
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user, :mod

  # @see AssessmentFlow#retake
  #
  # @return [Integer]
  def save!
    return if answers.empty? # we should not create an attempt if there is no questions answered

    user_assessment = create_user_assessment

    if answers.all?(&:persisted?) && user_assessment.persisted?
      answers.where(archived: false).update_all(user_assessment_id: user_assessment.id)
      completed(user_assessment.id)
    end
  end

  # @param user_assessment_id [UserAssessment.id]
  def completed(user_assessment_id)
    if answers.length == questions.length
      user_assessment_to_complete = UserAssessment.find_by(id: user_assessment_id)
      user_assessment_to_complete.update!(completed: Time.zone.now)
    end
  end

  # @return [Integer]
  def archive_attempt
    answers.update_all(archived: true)
  end

  def result_passed?
    user.user_assessments.where(assessments_type: CONFIDENCE, module: mod.name).where.not(completed: [nil]).order(completed: :asc).empty?
  end

private

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def answers
    user.user_answers.not_archived.where(assessments_type: CONFIDENCE, module: mod.name)
  end

  # @return [ConfidenceQuestionnaire]
  def questions
    @questions ||= ConfidenceQuestionnaire.where(training_module: mod.name)
  end

  # @return [UserAssessment]
  def create_user_assessment
    UserAssessment.create!(
      user_id: user.id,
      # score: We do not track scores for this assessment
      # status: We do not track satus for this assessment
      module: mod.name,
      # archived: no-op
      # completed: Used to populate only when user has completed the assessment
      assessments_type: CONFIDENCE,
    )
  end
end
