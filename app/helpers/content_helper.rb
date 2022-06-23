module ContentHelper
  # @return [String] GDS formatted markdown as HTML
  def translate_markdown(markdown)
    raw GovspeakDecorator.translate_markdown(markdown)
  end

  def print_button(*additional_classes)
    button = '<button class="govuk-link gem-c-print-link__button" onclick="window.print()" data-module="print-link" >Print this page</button>'.html_safe
    classes = ['gem-c-print-link', 'print-button'] + additional_classes
    content_tag :div, button, class: classes
  end
end
