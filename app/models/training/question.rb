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

    # @return [Boolean]
    def skippable?
      !always_show_question
    end

    # @return [String] powered by JSON not type
    def to_partial_path
      return 'training/questions/opinion_radio_buttons' if feedback_question?

      partial = multi_select? ? 'check_boxes' : 'radio_buttons'
      partial = "learning_#{partial}" if formative_question?
      "training/questions/#{partial}"
    end

    # @return [Boolean]
    def multi_select?
      confidence_question? || feedback_question? ? false : answer.multi_select?
    end

    def feedback_question?
      page_type == 'feedback'
    end

    # @return [Boolean] feedback free text
    def free_text?
      feedback_question? && options.empty?
    end

    # @return [Boolean]
    def has_hint?
      hint.present?
    end

    # @return [Boolean]
    def has_other?
      other.present?
    end

    # @param index [Integer]
    # @return [Boolean]
    def is_last_option?(index)
      options.count == index
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

    # @return [Boolean] event tracking
    def first_feedback?
      parent.opinion_questions.first.eql?(self)
    end

    # @return [Boolean] event tracking
    def last_feedback?
      parent.opinion_questions.last.eql?(self)
    end

    # @return [Boolean]
    def true_false?
      return false if multi_select?

      answer.options.map(&:label).sort.eql? %w[False True]
    end

    # TODO: Non longer required if Rails.application.migrated_answers?
    # @return [String]
    def assessments_type
      {
        formative_questionnaire: 'formative_assessment',
        summative_questionnaire: 'summative_assessment',
        confidence_questionnaire: 'confidence_check',
        feedback: 'feedback',
      }.fetch(page_type.to_sym)
    end

    # TODO: remove once CMS model page_types have suffix removed
    # @return [String]
    def question_type
      {
        formative_questionnaire: 'formative',
        formative: 'formative',
        summative_questionnaire: 'summative',
        summative: 'summative',
        confidence_questionnaire: 'confidence',
        feedback: 'feedback',
        confidence: 'confidence',
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
      elsif feedback_question?
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
