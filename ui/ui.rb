class Ui
  include Pages::Base

  def method_missing(method_name)
    pages[method_name] ||= "Pages::#{method_name.to_s.demodulize.camelize}".constantize.new
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?(/^[a-z]+/) || super
  end

private

  def pages
    @pages ||= {}
  end
end
