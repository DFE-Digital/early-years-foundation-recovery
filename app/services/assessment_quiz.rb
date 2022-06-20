class AssessmentQuiz

  def initialize(user:, type:, training_module_id:, name:)
    @user = user
    @type = type
    @training_module_id = training_module_id
    @name = name
    @questions_incorrect = []
  end

  def questions_list
    @questions_list ||= SummativeQuestionnaire.where(training_module: @training_module_id)
  end

  def user_saved_answers
    @user_saved_answers ||= @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: true)
  end

  def user_saved_answers
    @user_saved_answers ||= @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: true)
  end

  def user_saved_incorrect_answers
    @user_incorrect_answers ||= @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: false)
  end

  def percentage_of_answers_correct
    @percentage_of_answers_correct ||= ((user_saved_answers.length / questions_list.length.to_f) * 100).round(0)
  end

  # def populate_questionnaire(name, training_module)
  #   Questionnaire.find_by!(name: name, training_module: training_module)
  # end

  def questionnaire(name:, training_module:)
    Questionnaire.find_by!(name: name, training_module: training_module)
  end

  def questions_incorrect
    @questions_incorrect
  end
end