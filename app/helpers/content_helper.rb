module ContentHelper
  def translate_markdown(markdown)
    # FIXME: govspeak causes sass issues that require rails-sass
    # doc = Govspeak::Document.new markdown
    doc = Kramdown::Document.new markdown
    raw doc.to_html
  end
end
