# Page model for pages with module_item specific content
#
# Pagination is optional for these pages based on type
#
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
    translate(:heading)
  end

  # @return [String]
  def body
    translate(:body)
  end

  # @return [Boolean]
  def notes
    translate(:notes).present?
  end
  alias_method :notes?, :notes

  # @return [Boolean]
  def page_numbers?
    case module_item.type
    when /intro|thankyou/ then false
    else
      true
    end
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end
end
