require_relative 'content'

module Training
  class Question < Content
    def page_type = nil

    # @return [String]
    def self.content_type_id
      'question'
    end

    # # @return [Training::Question]
    # def self.by_id(id)
    #   load_children(0).find(id)
    # end

    # # @return [Training::Question]
    # def self.by_name(name)
    #   load_children(0).find_by(name: name).first
    # end
  end
end
