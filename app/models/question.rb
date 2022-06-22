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
      ans = []
      aswers_user = answer.each { |string| ans.push(string.to_s) }
      questionnaire.send("#{name}=", answer.map(&:to_sym)) # assemment result check for this value need to change this behaviour
      questionnaire.send("user_answers=", ans) # so the checkbox can be selected
    else
      begin
        questionnaire.send("#{name}=", answer.first.to_sym)
        questionnaire.send("user_answers=", answer.to_s) # so the checkbox can be selected
      rescue StandardError
        nil
      end
    end
  end
end
