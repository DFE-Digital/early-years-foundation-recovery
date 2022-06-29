class Questionnaire < OpenStruct
  def self.find_by!(args)
    if SummativeQuestionnaire.find_by(args)
      questionnaire_data = SummativeQuestionnaire.find_by(args)
    elsif QuestionnaireData.find_by(args)
      questionnaire_data = QuestionnaireData.find_by(args)
    elsif ConfidenceQuestionnaire.find_by(args)
      questionnaire_data = ConfidenceQuestionnaire.find_by(args)
    end

    begin
      questionnaire_data.build_questionnaire
    rescue StandardError
      nil
    end
  end

  include ActiveModel::Validations
  include TranslateFromLocale

  validate :correct_answers_exceed_threshold

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  def to_param
    name
  end

  # @return [String] plain text content
  def heading
    translate(:heading)
  end

  # @return [String] unparsed govspeak content
  def body
    translate(:body)
  end

  # @return [Array] list of question ostruct objects
  def question_list
    questions.map { |name, attrs| Question.new(attrs.merge(questionnaire: self, name: name)) }
  end

private

  def correct_answers_exceed_threshold
    return if required_percentage_correct&.zero?

    return if required_percentage_correct.present? && required_percentage_correct <= percentage_of_answers_correct

    results.each do |question, result|
      errors.add(question, 'is wrong') unless result
    end
  end

  def results
    @results ||= questions.each_with_object({}) do |(question, data), hash|
      hash[question] = if data[:correct_answers].present?
                         flattened_array(Array(send(question)).map(&:to_s)) == flattened_array(data[:correct_answers])
                       else
                         true # If there are no correct answers set, assume any answer much be true
                       end
    end
  end

  def number_of_correct_answers
    results.values.tally.fetch(true, 0)
  end

  def percentage_of_answers_correct
    (number_of_correct_answers / questions.length.to_f) * 100
  end

  def flattened_array(item)
    [item].flatten.select(&:present?)
  end
end
