class ConfidenceQuestionnaire < QuestionnaireData
  extend YamlFolder
  set_folder 'confidence-questionnaires'

  def self.load_file
    data = raw_data.map do |training_module, questionnaires|
      questionnaires.each_with_index.map do |(name, field), index|
        field['assessments_type'] = 'confidence_check'
        field['name'] = name
        field['training_module'] = training_module
        field['questions'].deep_symbolize_keys!

        field['page_number'] = index + 1
        field['total_questions'] = questionnaires.count

        field['questions'].map do |_question_key, defaults|
          defaults[:multi_select] = false
          defaults[:assessment_summary] = 'Thank you'
          defaults[:assessment_fail_summary] = 'Thank you'
          defaults[:answers] = {
            1 => 'Strongly agree',
            2 => 'Agree',
            3 => 'Neither agree nor disagree',
            4 => 'Disagree',
            5 => 'Strongly disagree',
          }
          defaults[:correct_answers] = (1..5).to_a
        end

        field
      end
    end

    data.flatten!
  end
end
