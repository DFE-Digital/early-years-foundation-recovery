class Training::QuestionResponse
  # @param user [User]
  # @param question [Training::Question]
  def initialize(user:, question:)
    @user = user
    @question = question
    @submitted_answers = []
  end

  # @!attribute [r] user
  #   @return [User]
  # @!attribute [r] question
  #   @return [Training::Question]
  attr_reader :user, :question
  
  # @!attribute [rw] answers
  #   @return [Array]
  attr_accessor :submitted_answers

  # Fill with persisted answers
  #
  # @return [nil, true]
  def prepare
    populate(answer_data) if answer_data.any?
  end

  # Update with new form input
  #
  # @param params [Hash{Symbol => String}]
  #
  # @return [nil, true]
  def populate(params)
    return if params.empty?
    
    submited_answers = Array(params[question.id])
  end

  # @return [Array<UserAnswer>]
  def persist
    if submitted_answers.present?
      user.user_answers.create!(
        assessments_type: question.component,
        module: question.module_id,
        name: question.name,
        questionnaire_id: question.id,
        question: question.id,
        answer: submitted_answers,
        correct: questionnaire.result_for(key),
      )
    end
  end

  # @return [Integer]
  def archive
    existing_user_answers.update_all(archived: true)
  end

private

  # @return [Hash{Symbol => Array<Integer>}]
  def answer_data
    existing_user_answers.pluck(:question, :answer).to_h.symbolize_keys
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def existing_user_answers
    user.user_answers.not_archived.where(
      assessments_type: question.assessments_type,
      module: question.module_id,
      name: question.slug,
    )
  end
end
