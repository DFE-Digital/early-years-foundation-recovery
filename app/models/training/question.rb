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

    # @see Answer
    delegate :options, :multi_select?, :correct_answers, to: :answer

    # @return [Hash{Symbol => nil, Integer}]
    def pagination
      return super if formative_question?

      question_group = summative_question? ? parent.summative_questions : parent.confidence_questions

      { current: question_group.find_index(self) + 1, total: question_group.count }
    end

    # @raise [Dry::Struct::Error] if JSON is invalid
    # @return [Training::Answer]
    def answer
      @answer ||= Answer.new(json: confidence_question? ? CONFIDENCE_OPTIONS : fields[:answers])
    end

    # @return [Boolean]
    def first_confidence?
      parent.confidence_questions.first.eql?(self)
    end

    # @return [Boolean]
    def first_assessment?
      parent.summative_questions.first.eql?(self)
    end

    # @return [Boolean]
    def last_assessment?
      parent.summative_questions.last.eql?(self)
    end

    # @return [String]
    def next_button_text
      if summative_question?
        last_assessment? ? 'Finish test' : 'Save and continue'
      else
        'Next'
      end
    end
  end
end
