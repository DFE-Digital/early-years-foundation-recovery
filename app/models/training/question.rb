module Training
  class Question < Content
    # @return [String]
    def self.content_type_id
      'question'
    end

    # @see Answer
    delegate :options, :correct_answers, to: :answer

    # @raise [Dry::Struct::Error]
    # @return [Training::Answer]
    def answer
      @answer ||= Answer.new(json: json)
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

    # TODO remove once user_answers is removed
    # @return [String]
    def assessments_type
      {
        formative_questionnaire: 'formative_assessment',
        summative_questionnaire: 'summative_assessment',
        confidence_questionnaire: 'confidence_check',
      }.fetch(page_type.to_sym)
    end

    def question_type
      {
        formative_questionnaire: 'formative',
        summative_questionnaire: 'summative',
        confidence_questionnaire: 'confidence',
      }.fetch(page_type.to_sym)
    end

    # @return [Array<String, Hash>]
    def schema
      [name, page_type, body, answer.schema, question_type]
    end

    # @return [String]
    def heading
      body
    end

    # @see ApplicationHelper#html_title
    # @return [String]
    def title
      name
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
        "#{body} (Select one answer)"
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

  private

    # @return [Array<Array>]
    CONFIDENCE_OPTIONS = [
      ['Strongly agree', true],
      ['Agree', true],
      ['Neither agree nor disagree', true],
      ['Disagree', true],
      ['Strongly disagree', true],
    ].freeze

    # @note Default values are not available to Contentful JSON fields
    # @return [Array<Array>]
    DRAFT_OPTIONS = [
      ['Wrong answer'],
      ['Correct answer', true],
    ].freeze

    # @return [Array<Array>]
    def json
      return CONFIDENCE_OPTIONS if confidence_question?

      fields[:answers] || DRAFT_OPTIONS
    end
  end
end
