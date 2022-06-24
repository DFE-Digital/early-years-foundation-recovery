module AssessmentQuestions
  def populate_questionnaire_results(module_question, question_input)
    return if question_input.empty?
    
    questionnaire = Questionnaire.find_by!(name: module_question[0][:name], training_module: module_question[0][:training_module])
    questionnaire.question_list.each do |question|
      answer = [question_input[question.name]].flatten.select(&:present?)
      question.set_answer(answer: answer) if answer.present?
    end

    questionnaire.submitted = true if question_input.answer.present?
  end

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: training_module)
  end

  def training_module
    @training_module ||= params[:training_module_id]
  end

  def questionnaire_params
    @questionnaire_params ||= params.require(:questionnaire).permit(permitted_methods)
  end

  # An attribute is permitted if it is defined in the questionnaire's YAML data
  # Added complication because multi-choice questions need to be set as hash within `permit` call
  # as they are submitted as an array within params
  def permitted_methods
    questionnaire.questions.map do |question, data|
      data[:multi_select] ? { question =>[]} : question
    end
  end

  def populate_questionnaire(question_input)
    return if question_input.empty?

    questionnaire.question_list.each do |question|
      answer = [question_input[question.name]].flatten.select(&:present?)
      question.set_answer(answer: answer)
    end
    questionnaire.submitted = true
  end

  def archive_previous_user_answers
    existing_user_answers.update_all(archived: true)
  end

  def existing_user_answers
    current_user.user_answers.not_archived.where(assessments_type:questionnaire.assessments_type, module:questionnaire.training_module, name:questionnaire.name)
  end

  def save_answers
    questionnaire.questions.each do |question, data|
      answer = Array(questionnaire.send(question))
      next if answer.empty?

      current_user.user_answers.create!(
        assessments_type: questionnaire.assessments_type,
        module: questionnaire.training_module,
        name: questionnaire.name,
        questionnaire_id: questionnaire.id,
        question: question,
        answer: answer,
        correct: flattened_array(answer.map(&:to_s)) == flattened_array(data[:correct_answers]),
      )
    end
  end

  def flattened_array(item)
    [item].flatten.select(&:present?)
  end

  def check_empty(param_to_check)
    questionaire_param = param_to_check.compact_blank
    (questionaire_param.blank?) ? false : true
  end

  def validate_param_empty
    validate_param = []

    questionnaire.questions.map do |question, data|
      validate_param = data[:multi_select] ? check_empty(params[:questionnaire][question]) : params.key?(:questionnaire)
    end
    validate_param
  end
end