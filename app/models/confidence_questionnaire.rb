class ConfidenceQuestionnaire < YamlBase
  extend YamlFolder

  set_folder 'confidence-questionnaires'

  def self.load_file
    data = raw_data.map do |training_module, questionnaires|
      questionnaires.map do |name, field|
        field['assessments_type'] = 'confidence_check'
        field['name'] = name
        field['training_module'] = training_module
        field['questions'].deep_symbolize_keys!
        field
      end
    end
    data.flatten! # Using flatten! as more memory efficient.
    data
  end

  def build_questionnaire
    # Need to deeply duplicate attributes as otherwise changes to questionnaire questions will be replicated
    # across all instances of a given questionnaire.
    attrs = attributes.deep_dup
    attrs[:confidence_questionnaire_data] = self
    Questionnaire.new(attrs)
  end
end
