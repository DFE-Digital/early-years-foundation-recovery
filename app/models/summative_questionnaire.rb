class SummativeQuestionnaire < QuestionnaireData
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
    data.flatten!
  end
end
