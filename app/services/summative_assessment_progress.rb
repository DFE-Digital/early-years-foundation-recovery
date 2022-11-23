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
    user_assessment = create_user_assessment

    if answers.all?(&:persisted?) && user_assessment.persisted?
      answers.update_all(user_assessment_id: user_assessment.id)
    end
  end

  # @return [Array<Question>]
  def wrong_answers_feedback
    array = []
    incorrect_answers.each do |user_answer|
      questionnaire = find_questionnaire(name: user_answer.name)

      questionnaire.question_list.each do |question|
        question.submit_answers(user_answer.answer)

        array << question
      end
    end
    array
  end

  # @see ContentHelper#results_banner
  #
  # @return [Hash]
  def result
    { success: passed?, score: score.to_i }
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

  # @see AssessmentResultsController#new
  #
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
      # completed: no-op
      assessments_type: 'summative_assessment',
    )
  end
end
