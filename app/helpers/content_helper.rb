module ContentHelper
  # @return [String] GDS formatted markdown as HTML
  def translate_markdown(markdown)
    raw GovspeakDecorator.translate_markdown(markdown)
  end
end
