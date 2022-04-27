class Question < OpenStruct
  def self.find_by!(args)
    query = args.except(:question)
    name = args[:question]
    question = Questionnaire.find_by!(query).questions[name]
    Question.new(question.merge(name: name))
  end

  def to_partial_path
    multi_select? ? 'shared/question_check_boxes' : 'shared/question_radio_buttons'
  end
end