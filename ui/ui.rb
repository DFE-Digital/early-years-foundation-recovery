class Ui
  attr_reader :inflector

  # include Pages::Base

  # Set class defaults
  def initialize
    @inflector = Dry::Inflector.new
  end

  # Dynamic method naming
  #
  # @param [String] method_name name
  # @return [Pages] A page instance
  def method_missing(method_name, *attrs)
    pages[method_name] ||= get_constantized_instance_name(method_name).new(*attrs)
  end

  # Required respond to missing method when using method_missing
  #
  # @param [String] method_name string arg.
  def respond_to_missing?(method_name, include_private = false)
    get_constantized_instance_name(method_name)
  rescue NameError => _e
    super
  end

private

  # convenience method to setup dynamic method body
  #
  # @param [String] method_name text input
  def get_constantized_instance_name(method_name)
    camelized_method = @inflector.camelize("Pages/#{method_name}")
    @inflector.constantize(camelized_method)
  end

  # Sets pages type if unset
  #
  # @return pages instance
  def pages
    @pages ||= {}
  end
end
