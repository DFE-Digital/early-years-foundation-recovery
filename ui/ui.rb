class Ui
  include Pages::Base

  def method_missing(method_name)
    pages[method_name] ||= "Pages::#{method_name.to_s.demodulize.camelize}".constantize.new
  end

  def respond_to_missing?(method_name, include_private = false)
    "Pages::#{method_name.to_s.demodulize.camelize}".constantize
  rescue NameError => _e
    super
  end

private

  def pages
    @pages ||= {}
  end
end
