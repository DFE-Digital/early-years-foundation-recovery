# Summative assessment evaluation
#
class SummativeAssessmentProgress
  # @param user [User]
  # @param mod [TrainingModule]
  def initialize(user:, mod:)
    @user = user
    @mod = mod
  end

  attr_reader :user, :mod

  # @see QuestionnairesController#marked_assessment
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

  # @return [Array<Question>]
  def wrong_answers_feedback
    array = []
    incorrect_attempt_answers.each do |user_answer|
      questionnaire = find_questionnaire(name: user_answer.name)

      questionnaire.question_list.each do |question|
        question.submit_answers(user_answer.answer)

        array << question
      end
    end
    array
  end

  # @param user_assessment_id [UserAssessment.id]
  def completed(user_assessment_id)
    if answers.length == questions.length
      user_assessment_to_complete = UserAssessment.find_by(id: user_assessment_id)
      user_assessment_to_complete.update!(completed: Time.zone.now)
    end
  end

  # @see ContentHelper#results_banner
  #
  # @return [Hash]
  def result
    { success: result_passed?, score: last_attempt.score.to_i }
  end

  # @raise [NoMethodError] Somtimes in the code when user visits the question there will not be any last attempt
  #
  # @return [Boolean]
  def result_passed?
    last_attempt.score.to_i >= mod.summative_threshold
  rescue NoMethodError
    false
  end

  # @see #passed?
  #
  # @return [Symbol]
  def status
    passed? ? :passed : :failed
  end

  # @return [Boolean]
  def failed?
    !passed?
  end

  # @return [Boolean]
  def passed?
    score >= mod.summative_threshold
  end

  # @return [Boolean] CTA failed_attempt state
  def attempted?
    user.user_assessments.where(assessments_type: 'summative_assessment', module: mod.name).any?
  end

  # @return [Integer]
  def archive_attempt
    answers.update_all(archived: true)
  end

  # End of assessment score for many questions
  #
  # @return [Float] percentage of correct answers
  def score
    (correct_answers.count.to_f / questions.count) * 100
  rescue ZeroDivisionError
    0.0
  end

  # @return [UserAssessments::ActiveRecord_AssociationRelation]
  def last_attempt
    user.user_assessments.where(assessments_type: 'summative_assessment', module: mod.name).where.not(completed: [nil]).order(completed: :asc).last
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def attempt_answers
    user.user_answers.where(assessments_type: 'summative_assessment', module: mod.name, user_assessment_id: last_attempt.id)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def incorrect_attempt_answers
    attempt_answers.where(correct: false)
  end

private

  # @return [Questionnaire]
  def find_questionnaire(name:)
    Questionnaire.find_by!(name: name, training_module: mod.name)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def incorrect_answers
    answers.where(correct: false)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def correct_answers
    answers.where(correct: true)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def attempt_correct_answers
    attempt_answers.where(correct: true)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def answers
    user.user_answers.not_archived.where(assessments_type: 'summative_assessment', module: mod.name)
  end

  # @return [SummativeQuestionnaire]
  def questions
    @questions ||= SummativeQuestionnaire.where(training_module: mod.name)
  end

  # @return [UserAssessment]
  def create_user_assessment
    UserAssessment.create!(
      user_id: user.id,
      score: score.to_i,
      status: status,
      module: mod.name,
      # archived: no-op
      assessments_type: 'summative_assessment',
    )
  end
end
