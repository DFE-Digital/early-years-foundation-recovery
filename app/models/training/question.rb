class Training::Question < ContentfulModel::Base
  self.content_type_id = 'question'
  
  include ActiveModel::Validations
  has_many :answers, class_name: 'Training::Answer'

  attr_reader :name, :training_module, :label
  alias_method :slug, :name
  alias_method :module_id, :training_module
  alias_method :body, :label

  attr_accessor :submitted
 
  # @return [ModuleItem]
  def module_item
    @module_item ||= Training::Page.find_by(module_id: module_id, slug: slug).first
  end
  alias_method :page, :module_item

  # @return [String]
  def to_param
    slug 
  end
  
  # @return [Hash{Symbol => nil, Integer}]
  def pagination
    return module_item.pagination if formative?

    { current: page_number, total: total_questions }
  end

  # @return [Boolean]
  def multi_select?
    !!multi_select
  end

  # @return [Boolean]
  def formative?
    component.eql?('formative')
  end

  # @return [Boolean]
  def summative?
    component.eql?('summative')
  end
  
  # OPTIMIZE: There is only ever one question
  #
  # @return [Array<Question>]
  def question_list
    [self]
  end

  def assessments_type
    component + '_assessment'
  end
  
  # @return [Boolean]
  def first_confidence?
    module_item.parent.confidence_questions.first.eql?(module_item)
  end
  
  # @return [Boolean]
  def first_assessment?
    module_item.parent.summative_questions.first.eql?(module_item)
  end
  
  # @return [String]
  def to_partial_path
    fields = multi_select? ? :check_boxes : :radio_buttons
    "training/questions/#{component}_questionnaire_#{fields}"
  end

  # @return [Boolean]
  def legend_hidden?
    label.nil?
  end

  # @return [Boolean]
  def submitted?
    !!submitted
  end

  # @return [Boolean]
  def answered?
    false
    #submitted_answers.any?
  end

  # @return [String]
  def next_button_text
    if summative?
      last_assessment? ? 'Finish test' : 'Save and continue'
    else
      'Next'
    end
  end

  def correct_answers
    answers.select{|answer| answer.correct }.map &:body
  end

  # @return [String]
  def debug_summary
    <<~SUMMARY

      ---
      correct answer(s): #{correct_answers}
    SUMMARY
  end

end
