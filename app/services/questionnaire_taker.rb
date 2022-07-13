class QuestionnaireTaker
  # @param user [User]
  # @param questionnaire [Questionnaire]
  def initialize(user:, questionnaire:)
    @user = user
    @questionnaire = questionnaire
  end

  attr_reader :user, :questionnaire

  # Fill with persisted answers
  #
  # @return [nil, ?]
  def prepare
    existing_answers = existing_user_answers.pluck(:question, :answer)
    populate(existing_answers.to_h.symbolize_keys) if existing_answers.any?
  end

  # Update with new input
  #
  # @param params [Hash{Symbol => String}]
  #
  # @return [nil, true]
  def populate(params)
    return if params.empty?

    questionnaire.question_list.each do |question|
      answers = Array(params[question.name]) # String / Array<String>
      question.submit_answers(answers)
    end

    questionnaire.submitted = true
  end

  # @return [Array<UserAnswer>]
  def persist
    questionnaire.questions.each_key.map do |key|
      answers = questionnaire.answer_for(key)

      next if answers.empty?

      user.user_answers.create!(
        assessments_type: questionnaire.assessments_type,
        module: questionnaire.training_module,
        name: questionnaire.name,
        questionnaire_id: questionnaire.id,
        question: key,
        answer: answers,
        correct: questionnaire.result_for(key),
      )
    end
  end

  # @return [Integer]
  def archive
    existing_user_answers.update_all(archived: true)
  end

  # @return [UserAnswer::ActiveRecord_AssociationRelation]
  def existing_user_answers
    user.user_answers.not_archived.where(
      assessments_type: questionnaire.assessments_type,
      module: questionnaire.training_module,
      name: questionnaire.name,
    )
  end
end
