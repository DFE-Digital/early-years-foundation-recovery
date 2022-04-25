class Questionnaire < OpenStruct
  def self.find_by!(args)
    questionnaire_data = QuestionnaireData.find_by!(args)
    questionnaire_data.build_questionnaire
  end

  include ActiveModel::Validations

  validate :correct_answers_exceed_threshold

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  def to_param
    name
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
                         send(question) == data[:correct_answers]
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
end
