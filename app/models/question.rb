class Question < OpenStruct
  def self.find_by!(args)
    query = args.except(:question)
    name = args[:question]
    questionnaire = Questionnaire.find_by!(query)
    question = questionnaire.questions[name]
    Question.new(question.merge(questionnaire: questionnaire, name: name))
  end

  def to_partial_path
    !!multi_select ? 'shared/question_check_boxes' : 'shared/question_radio_buttons'
  end

  def set_answer(answer:)
    if multi_select
      questionnaire.send("#{name}=", answer.map(&:to_sym))
    else
      questionnaire.send("#{name}=", answer&.first.to_sym)
    end
  end
end
