module Training
  class Question < Content
    # @return [String]
    def self.content_type_id
      'question'
    end
  
    def options
      answers.map do |option|
        OpenStruct.new(id: option.keys[0].to_s, label: option.values[0][0], correct?: option.values[0][1] )
      end
    end

    def correct_answer
      correct_options = options.select{|option| option.correct? }.map(&:id)
      correct_options.count == 1 ? correct_options.first : correct_options
    end

  end
end
