class SummativeQuestionnaire < YamlBase
  extend YamlFolder

  set_folder 'summative-questionnaires'
  def self.load_file
    data = raw_data.map do |training_module, questionnaires|
      questionnaires.each_with_index.map do |(name, field), index|
        field['assessments_type'] = 'summative_assessment'
        field['name'] = name
        field['training_module'] = training_module
        field['questions'].deep_symbolize_keys!
        field['page_number'] = index + 1
        field['total_questions'] = questionnaires.count
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
    attrs[:summative_questionnaire_data] = self
    Questionnaire.new(attrs)
  end
end
