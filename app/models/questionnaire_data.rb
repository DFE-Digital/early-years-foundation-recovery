# ActiveYaml objects are effectively singletons.
#
# That is, each one is loaded into memory at application start and processes
# like `find_by` grab the matching instance and return that rather than spawning
# a new matching instance.
#
# That adds complications when using instances to populate forms and hold per-transaction data.
# Data from one transaction can pollute another as both share the same singleton instance.
#
# Therefore, the questionnaires model is split into two:
#
#   - QuestionnaireData - holds the unchanging questionnaire structure as defined via YAML files
#   - Questionnaire - handles the transactions that occur when a user interacts with a questionnaire
#
class QuestionnaireData < YamlBase
  # Need to deeply duplicate attributes as otherwise changes to questionnaire
  # questions will be replicated across all instances of a given questionnaire.
  def build_questionnaire
    attrs = attributes.deep_dup
    attrs[:questionnaire_data] = self
    Questionnaire.new(attrs)
  end
end
