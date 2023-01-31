require_relative 'content'

module Training
  class Question < Content
    def page_type = nil

    # @return [String]
    def self.content_type_id
      'question'
    end
  end
end
