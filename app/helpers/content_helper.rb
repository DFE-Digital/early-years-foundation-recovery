module ContentHelper
  # @return [String] GDS formatted markdown as HTML
  def translate_markdown(markdown)
    return if markdown.blank?

    raw GovspeakDecorator.translate_markdown(markdown)
  end

  def govuk_heading(text, tag: :h1)
    return if text.blank?

    content_tag tag, class: 'govuk-heading-m' do
      text
    end
  end

  def print_button(*additional_classes)
    button = '<button class="govuk-link gem-c-print-link__button" onclick="window.print()" data-module="print-link" >Print this page</button>'.html_safe
    classes = ['gem-c-print-link', 'print-button'] + additional_classes
    content_tag :div, button, class: classes
  end
end
