require_relative 'content'

module Training
  class Page < Content
    # @return [String]
    def self.content_type_id
      'page'
    end

    # # @return [Training::Page]
    # def self.by_id(id)
    #   load_children(0).find(id)
    # end
  end
end
