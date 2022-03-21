module ContentHelper
  def translate_markdown(markdown)
    doc = Kramdown::Document.new markdown
    raw doc.to_html
  end
end
