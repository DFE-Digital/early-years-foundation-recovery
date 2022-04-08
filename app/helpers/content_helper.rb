module ContentHelper
  # @return [String] GDS formatted markdown as HTML
  def translate_markdown(markdown)
    raw Govspeak::Document.new(markdown).to_html
  end
end
