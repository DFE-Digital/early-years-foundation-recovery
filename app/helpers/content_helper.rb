module ContentHelper
  def translate_markdown(markdown)
    doc = Govspeak::Document.new markdown
    raw doc.to_html
  end
end
