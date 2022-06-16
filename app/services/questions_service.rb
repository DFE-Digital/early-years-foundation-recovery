module QuestionsService
  def summative_questions(training_module_id)
    SummativeQuestionnaire.where(training_module: training_module_id)
  end

  def questions_key(questions_list)
    questions_list.map { |u| u.questions.keys[0] }
  end

  def users_answered_questions(question_lists)
    current_user.user_answers.not_archived.where(question: question_lists)
  end

  def merge_summative_users_answers(summative_questions, users_answers)
    question_populated = []
    users_answers.map{ |q|
      module_question = find_question_name(summative_questions, q.question)
      existing_answers = {:question => q.question, :answer => q.answer }
      question_populated.push(populate_questionnaire_results(module_question, existing_answers.to_h.symbolize_keys)) if existing_answers.present?
    }

    puts question_populated
  end

  def find_question_name(summative_questions, question)
    summative_questions.select{ |key| key.questions.keys[0].to_s === question.to_s }
  end

  def populate_questionnaire_results(module_question, question_input)
    return if question_input.empty?

    questionnaire = Questionnaire.find_by!(name: module_question[0][:name], training_module: module_question[0][:training_module])
    questionnaire.question_list.each do |question|
      answer = [question_input[question.name]].flatten.select(&:present?)
      question.set_answer(answer: answer) if answer.present?
    end

    puts questionnaire.inspect
    questionnaire.submitted = true
  end

  def process_questionaire
    if questionnaire_params.values.all?(&:present?)
      populate_questionnaire(questionnaire_params)
      save_answers
      flash[:alert] = nil
    else
      flash[:alert] = 'Please select an answer'
    end
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
      data[:multi_select] ? { question => [] } : question
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
    current_user.user_answers.not_archived.where(questionnaire_id: questionnaire.id)
  end

  def save_answers
    questionnaire.questions.each do |question, data|
      answer = Array(questionnaire.send(question))
      next if answer.empty?

      current_user.user_answers.create!(
        questionnaire_id: questionnaire.id,
        question: question,
        answer: answer,
        correct: answer == data[:correct_answers].map(&:to_sym),
      )
    end
  end
end