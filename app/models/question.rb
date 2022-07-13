class Question < OpenStruct
  def self.find_by!(args)
    query = args.except(:question)
    name = args[:question]
    questionnaire = Questionnaire.find_by!(query)
    question = questionnaire.questions[name]
    Question.new(question.merge(questionnaire: questionnaire, name: name))
  end

  # @return [String]
  def to_partial_path
    fields = multi_select? ? :check_boxes : :radio_buttons
    "shared/question_#{fields}"
  end

  # @return [Boolean] radio_buttons or check_boxes
  def multi_select?
    !!multi_select
  end

  # @return [Boolean]
  def answered?
    submitted_answers.any?
  end

  # @return [Boolean]
  def select?(answer)
    submitted_answers.include?(answer)
  end

  # Confidence check answers can be changed.
  # Assessment answers can not be changed once submitted.
  #
  # @return [Boolean]
  def disabled?
    return false if questionnaire.confidence_check?

    questionnaire.submitted?
  end

  # @return [Boolean]
  def legend_hidden?
    label.nil?
  end

  # NB: Must use this method to populate answers
  #
  # @param answers [Array<Mixed>]
  # @return [Array<Integer>]
  def submit_answers(answers)
    questionnaire[name] = coerce_answers(answers)
  end

  # @return [Array<Integer>]
  def submitted_answers
    questionnaire.answer_for(name)
  end

  # @return [Array<String>]
  def submitted_answers_values
    answers.slice(*submitted_answers).values
  end

  # [
  #   [1, "Correct answer 1", true],
  #   [2, "Wrong answer 1", false],
  #   [3, "Correct answer 2", true],
  #   [4, "Wrong answer 2", false],
  # ]
  #
  # @return [Array<Array>]
  def fields
    answers.map { |key, value| [key, value, select?(key)] }
  end

private

  # FIXME: existing persisted answer data is curently a String of an Array of Integers as Symbols
  #
  # Input Types:
  #
  # FORM: [Array<String>]
  # DB:   [Array<Symbol>]
  # YAML: [Array<Integer>]
  #
  # @param answers [Array<Mixed>] form input / db / YAML
  def coerce_answers(answers)
    answers.map(&:to_s).compact_blank.map(&:to_i)
    # TODO: swap to this once DB records are re-typed
    # answers.compact_blank.map(&:to_i)
  end
end
