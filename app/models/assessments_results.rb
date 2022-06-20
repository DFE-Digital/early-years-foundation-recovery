class AssessmentsResults < OpenStruct
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module

  validates :heading, :body, presence: true

  # @return [Hash, nil]
  delegate :page_number, to: :module_item

  # @return [String]
  def heading
    translate(:heading)
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
