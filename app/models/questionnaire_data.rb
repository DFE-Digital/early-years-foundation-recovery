# ActiveYaml objects are effectively singletons. That is, each one is loaded into memory at application start and
# processes like `find_by` grab the matching instance and return that rather than spawning a new matching instance.
# That adds complications when using instances to populate forms and hold per transaction data. Data from
# one transaction can pollute another as both share the same singleton instance. Therefore, the questionnaires model is
# split into two:
#   - QuestionnaireData - that holds the unchanging questionnaire structure as defined via YAML files
#   - Questionnaire - that handles the transactions that occur when a user interacts with a questionnaire

class QuestionnaireData < YamlBase
  extend YamlFolder

  set_folder 'questionnaires'

  def self.load_file
    data = raw_data.map do |training_module, questionnaires|
      questionnaires.map do |name, field|
        field['assessments_type'] = 'formative_assessment'
        # field['id'] = 6.times.map { rand(0..9) }.join # make the id longer so not duplicated by other questions models
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
    attrs[:questionnaire_data] = self
    Questionnaire.new(attrs)
  end
end
