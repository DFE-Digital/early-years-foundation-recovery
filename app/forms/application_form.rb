class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  class FormError < StandardError
  end

  # @return [OpenStruct]
  def parent
    OpenStruct.new(title: nil)
  end

  # @raise [FormError]
  def save
    raise FormError, "#{self.class.name}##{__method__} was not defined"
  end
end
