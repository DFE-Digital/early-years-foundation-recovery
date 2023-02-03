require_relative 'content'

module Training
  class Question < Content
    # @return [String]
    def self.content_type_id
      'question'
    end
  end
end
