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
    if static_page?
      I18n.t("#{type}.heading")
    else
      translate(:heading)
    end
  end

  # @return [String]
  def body
    if static_page?
      static_body
    else
      translate(:body)
    end
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

  # @return [Boolean]
  def summative?
    module_item.parent.summative?
  end

private

  # @return [Boolean]
  def static_page?
    module_item.confidence_intro? || module_item.assessment_intro? || module_item.ending_intro?
  end

  # @return [String]
  def static_body
    I18n.t(
      "#{type}.body",
      passmark: module_item.parent.summative_threshold,
      feedback_url: I18n.t("modules.#{training_module}.#{module_item.name}.url"),
    )
  end
end
