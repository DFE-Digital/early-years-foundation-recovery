module Training
  class Page < Content
    # @return [String]
    def self.content_type_id
      'page'
    end

    # @return [Boolean]
    def updated_content?
      created_at < updated_at
    end

    # @return [Array<String, Hash>]
    def schema
      [name, page_type, heading, (notes? ? { note: 'hello world' } : Types::EMPTY_HASH)]
    end
  end
end
