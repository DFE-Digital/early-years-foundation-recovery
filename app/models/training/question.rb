module Training
  class Question < Content
    # @return [String]
    def self.content_type_id
      'question'
    end

    def options
      answers.map do |option|
        OpenStruct.new(id: option.keys[0].to_s, label: option.values[0][0], correct?: option.values[0][1])
      end
    end

    def correct_answer
      correct_options = options.select(&:correct?).map(&:id)
      correct_options.count == 1 ? correct_options.first : correct_options
    end

    def formative?
      assessments_type.eql? 'formative_assessment'
    end

    def summative?
      assessments_type.eql? 'summative_assessment'
    end

    def confidence?
      assessments_type.eql? 'confidence_check'
    end

    def first_confidence?
      parent.confidence_questions.first.eql?(self)
    end

    def last_assessment?
      parent.summative_questions.last.eql?(self)
    end
  end
end
