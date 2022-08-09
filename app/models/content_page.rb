class ContentPage
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module

  validates :heading, :body, presence: true

  # @return [Hash]
  delegate :pagination, to: :module_item

  # @return [String]
  def heading
    !I18n.t("#{type}.heading").include?('translation missing') ? 
      I18n.t("#{type}.heading") : translate(:heading)
  end

  # @return [String]
  def body
    translate(:body)
  end

  # @return [String]
  def image
    translate(:image)
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  # Interruption page content is different for each type
  # @return [Boolean]
  def formative?
    module_item.parent.formative?
  end

  def summative?
    module_item.parent.summative?
  end
end
