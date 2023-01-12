module Training
  class Question < ContentfulModel::Base
    self.content_type_id = 'question'

    # For backward compatibility with Questionnaire
    def questions
      self
    end

    def keys
      [id.to_sym]
    end
  end
end
