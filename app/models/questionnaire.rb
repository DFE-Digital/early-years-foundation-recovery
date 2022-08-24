# TODO: Combine Questionnaire/Question
# TODO: Restructure YAML to remove #question_list
#
# submitted: boolean (answer)
#
class Questionnaire < OpenStruct
  # { name: '1-3-2-1', training_module: 'alpha' }
  #
  # @param args [Hash { Symbol => String}]
  # @raise [ActiveHash::RecordNotFound]
  # @return [nil, Questionnaire]
  def self.find_by!(args)
    questionnaire_data =
      if FormativeQuestionnaire.find_by(args)
        FormativeQuestionnaire.find_by(args)
      elsif SummativeQuestionnaire.find_by(args)
        SummativeQuestionnaire.find_by(args)
      elsif ConfidenceQuestionnaire.find_by(args)
        ConfidenceQuestionnaire.find_by(args)
      end

    raise ActiveHash::RecordNotFound if questionnaire_data.nil?

    questionnaire_data.build_questionnaire
  end

  include ActiveModel::Validations
  include TranslateFromLocale

  validate :check_answers

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  # @see YamlBase
  #
  # @return [String]
  def to_param
    name
  end

  # @return [String] plain text content
  def heading
    translate(:heading) || name
  end

  # @return [String] unparsed govspeak content
  def body
    translate(:body)
  end

  # @return [Hash{Symbol => nil, Integer}]
  def pagination
    return module_item.pagination if formative?

    { current: page_number, total: total_questions }
  end

  # OPTIMIZE: There is only ever one question
  #
  # @return [Array<Question>]
  def question_list
    questions.map do |name, attrs|
      Question.new(attrs.merge(questionnaire: self, name: name))
    end
  end

  # @return [Boolean]
  def formative?
    assessments_type.eql?('formative_assessment')
  end

  # @return [Boolean]
  def summative?
    assessments_type.eql?('summative_assessment')
  end

  # @return [Boolean]
  def confidence?
    assessments_type.eql?('confidence_check')
  end

  # @see QuestionnaireTaker#populate
  #
  # @return [Boolean] populated with answer input
  def submitted?
    !!submitted
  end

  # @return [Boolean] end of summative assessment
  def final_question?
    module_item.parent.last_assessment_page.eql?(module_item)
  end

  # @return [String]
  def next_button_text
    if summative?
      final_question? ? 'Finish test' : 'Save and continue'
    else
      'Next'
    end
  end

  # @param question [Question]
  # @return [Boolean]
  def answered?(question)
    answer_for(question.name).present?
  end

  # NB: Must use this method to query for answers
  #
  # @param key [Symbol]
  # @return [Array<Integer>]
  def answer_for(key)
    self[key] || []
  end

  # @return [Boolean]
  def result_for(key)
    results[key]
  end

  # @return [String]
  def summary_for(key)
    summary = result_for(key) ? :assessment_summary : :assessment_fail_summary
    questions.dig(key, summary)
  end

  # An attribute is permitted if it is defined in the questionnaire's YAML data
  # Added complication because multi-choice questions need to be set as hash within `permit` call
  # as they are submitted as an array within params
  #
  # @see AssessmentController#questionnaire_params
  def permitted_methods
    questions.map do |question, data|
      data[:multi_select] ? { question => [] } : question
    end
  end

  # @return [String]
  def debug_summary
    <<~SUMMARY
      id: #{id}
      name: #{training_module}
      path: #{name}
      type: #{type}

      ---
      previous: #{previous_item&.name}
      next: #{next_item&.name}

      ---
      submodule name: #{submodule_name || 'N/A'}
      topic name: #{topic_name || 'N/A'}
      page name: #{page_name || 'N/A'}

      ---

      ---
      submodule items count: #{number_within_submodule}
      topic items count: #{number_within_topic}
    SUMMARY
  end

private

  # Validations are not used in any logic currently
  #
  # @return [Hash{Symbol=>Boolean}]
  def check_answers
    results.each do |key, result|
      errors.add(key, 'is wrong') unless result
    end
  end

  # @return [Hash{Symbol => Boolean}]
  def results
    @results ||= questions.each_with_object({}) do |(key, _data), hash|
      hash[key] = !confidence? ? correct?(key) : true
    end
  end

  # @return [Integer] default zero
  def number_of_correct_answers
    results.values.tally.fetch(true, 0)
  end

  # @param key [Symbol]
  #
  # @return [Boolean]
  def correct?(key)
    answer_for(key) == correct_answer_for(key)
  end

  # @param key [Symbol]
  # @return [Array<Integer>]
  def correct_answer_for(key)
    questions[key][:correct_answers]
  end
end
