require_relative 'content'

module Contentful
  class Static < Content
    self.content_type_id = 'static'
  end
end
