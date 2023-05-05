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
    delegate :options, :correct_answers, to: :answer

    # @raise [Dry::Struct::Error] if JSON is invalid
    # @return [Training::Answer]
    def answer
      @answer ||= Answer.new(json: confidence_question? ? CONFIDENCE_OPTIONS : fields[:answers])
    end

    # @return [Hash{Symbol => nil, Integer}]
    def pagination
      return super if formative_question?

      question_group = summative_question? ? parent.summative_questions : parent.confidence_questions

      { current: question_group.find_index(self) + 1, total: question_group.count }
    end

    # @return [String] powered by JSON not type
    def to_partial_path
      partial = multi_select? ? 'check_boxes' : 'radio_buttons'
      partial = "learning_#{partial}" if formative_question?
      "training/questions/#{partial}"
    end

    # @return [Boolean]
    def multi_select?
      confidence_question? ? false : answer.multi_select?
    end

    # @return [Boolean] event tracking
    def first_confidence?
      parent.confidence_questions.first.eql?(self)
    end

    # @return [Boolean] event tracking
    def first_assessment?
      parent.summative_questions.first.eql?(self)
    end

    # @return [Boolean] event tracking
    def last_assessment?
      parent.summative_questions.last.eql?(self)
    end

    # @return [Boolean]
    def true_false?
      return false if multi_select?

      answer.options.map(&:label).sort.eql? %w[False True]
    end

    # @return [String]
    def assessments_type
      {
        formative_questionnaire: 'formative_assessment',
        summative_questionnaire: 'summative_assessment',
        confidence_questionnaire: 'confidence_check',
      }.fetch(page_type.to_sym)
    end

    # Demo content currently positions questions as topics which genuine content does not.
    # As a result, for example, questions appear in the module overview page.
    # For this reason Question#heading is required within the test suite.
    #
    # @return [String]
    def heading
      body
    end

    # @return [String]
    def legend
      if multi_select?
        "#{body} (Select all answers that apply)"
      elsif true_false?
        <<~LEGEND
          True or false?

          #{body}
        LEGEND
      else
        body
      end
    end

    # @return [String] decorator
    def next_button_text
      if summative_question?
        last_assessment? ? 'Finish test' : 'Save and continue'
      else
        'Next'
      end
    end
  end
end
