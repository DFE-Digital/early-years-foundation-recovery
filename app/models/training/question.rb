class Training::Question < ContentfulModel::Base
  self.content_type_id = 'question'

  has_many :answers, class_name: 'Training::Answer'

end