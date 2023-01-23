require_relative 'content'

class Training::Question < Content
  self.content_type_id = 'question'

  def page_type = nil
end