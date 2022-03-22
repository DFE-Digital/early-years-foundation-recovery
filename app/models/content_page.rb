class ContentPage
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module

  validates :heading, :body, presence: true

  def heading
    translate(:heading)
  end

  def body
    translate(:body)
  end

  def image
    translate(:image)
  end
end
