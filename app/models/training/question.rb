module Training
  class Question < Content
    # @return [String]
    def self.content_type_id
      'question'
    end

    # @return [Array<Array>]
    CONFIDENCE_OPTIONS = [
      ['Strongly agree', true],
      ['Agree', true],
      ['Neither agree nor disagree', true],
      ['Disagree', true],
      ['Strongly disagree', true],
    ].freeze

    delegate :options, :multi_select?, :correct_answers, to: :answer

    # @return [Training::Answer]
    def answer
      @answer ||= Answer.new(json: confidence? ? CONFIDENCE_OPTIONS : fields[:answers])
    end

    # @return [Boolean]
    def formative?
      assessments_type.eql? 'formative_assessment'
    end

    # @return [Boolean]
    def summative?
      assessments_type.eql? 'summative_assessment'
    end

    def confidence?
      assessments_type.eql? 'confidence_check'
    end

    def first_confidence?
      parent.confidence_questions.first.eql?(self)
    end

    def first_assessment?
      parent.summative_questions.first.eql?(self)
    end

    def last_assessment?
      parent.summative_questions.last.eql?(self)
    end

    # @return [String]
    def next_button_text
      if summative?
        last_assessment? ? 'Finish test' : 'Save and continue'
      else
        'Next'
      end
    end
  end
end
