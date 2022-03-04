class ContentPage
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :id, :type, :training_module

  validates :heading, :body, presence: true

  def i18n_scope
    [:modules, training_module, id]
  end

  def heading
    translate(:heading)
  end

  def body
    translate(:body)
  end

  def translate(label)
    # Suppress translation returning "translation missing" message so validation for presence works
    return unless I18n.exists?([i18n_scope, label])
    
    I18n.t(label, scope: i18n_scope)
  end
end
