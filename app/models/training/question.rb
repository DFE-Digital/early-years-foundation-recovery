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

    # @return [String] powered by JSON not type
    def to_partial_path
      partial = multi_select? ? 'check_boxes' : 'radio_buttons'

      if feedback_question?
        partial = 'text_area' if only_text?
        "feedback/#{partial}"
      else
        partial = "learning_#{partial}" if formative_question?
        "training/questions/#{partial}"
      end
    end

    # Factual questions: dynamic based on available correct options
    # Opinion questions:
    #   - Feedback (default: false)
    #   - Confidence (always: false)
    #   - Pre-Confidence (always: false)
    #
    # @return [Boolean]
    def multi_select?
      if feedback_question?
        !!multi_select
      elsif confidence_question? || pre_confidence_question?
        false
      else
        answer.multi_select?
      end
    end

    # @return [Boolean] textarea by itself no validations
    def only_text?
      options.empty? && has_more?
    end

    # @return [Boolean] "Could you give use reasons for your answer"
    def and_text?
      options.present? && !multi_select? && has_more?
    end

    # Turns the last "other" option input field into a textarea
    #
    # @return [Boolean]
    def has_more?
      feedback_question? && more.present?
    end

    # @return [Boolean]
    def has_other?
      feedback_question? && other.present?
    end

    # Additional "Or" option is appended and given index zero
    #
    # @return [Boolean]
    def has_or?
      feedback_question? && self.or.present?
    end

    # @return [Boolean] default: false
    def skippable?
      feedback_question? && !!skippable
    end

    # @return [Boolean] event tracking
    def first_confidence?
      parent.confidence_questions.first.eql?(self)
    end

    # @return [Boolean] event tracking
    def first_pre_confidence?
      parent.pre_confidence_questions.first.eql?(self)
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
    def first_feedback?
      parent.feedback_questions.first.eql?(self)
    end

    # @return [Boolean]
    def last_feedback?
      parent.feedback_questions.last.eql?(self)
    end

    # @return [Boolean]
    def true_false?
      return false if multi_select?

      answer.options.map(&:label).sort.eql? %w[False True]
    end

    # @return [Array<String, Hash>]
    def schema
      [name, page_type, body, answer.schema]
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
      elsif feedback_question? || pre_confidence_question?
        body.to_s
      else
        "#{body} (Select one answer)"
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

    # @return [Array<Array>]
    PRECONFIDENCE_OPTIONS = [
      ['Very confident', true],
      ['Somewhat confident', true],
      ['Neutral', true],
      ['Not very confident', true],
      ['Not confident at all', true],
    ].freeze

    # @note Default values are not available to Contentful JSON fields
    # @return [Array<Array>]
    DRAFT_OPTIONS = [
      ['Wrong answer'],
      ['Correct answer', true],
    ].freeze

    # @return [Array<Array>]
    def json
      return PRECONFIDENCE_OPTIONS if pre_confidence_question?
      return CONFIDENCE_OPTIONS if confidence_question?

      fields[:answers] || DRAFT_OPTIONS
    end
  end
end
