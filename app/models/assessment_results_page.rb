class AssessmentResultsPage < OpenStruct
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module

  validates :heading, :body, presence: true

  # @return [Hash]
  delegate :pagination, to: :module_item

  # @return [String]
  def heading
    translate(:heading) || name
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
end
