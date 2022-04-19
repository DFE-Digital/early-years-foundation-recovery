class Ui
  attr_reader :inflector

  include Pages::Base

  def initialize
    @inflector = Dry::Inflector.new
  end

  def method_missing(method_name)
    # camelized_method = @inflector.camelize("Pages/#{method_name}")
    pages[method_name] ||= get_constantized_instance_name(method_name).new
  end

  def respond_to_missing?(method_name, include_private = false)
    get_constantized_instance_name(method_name)
  rescue NameError => _e
    super
  end

private

  def get_constantized_instance_name(method_name)
    camelized_method = @inflector.camelize("Pages/#{method_name}")
    @inflector.constantize(camelized_method)
  end

  def pages
    @pages ||= {}
  end
end
