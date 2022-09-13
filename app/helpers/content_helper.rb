module ContentHelper
  # GDS formatted markdown as HTML
  # @param markdown [String]
  # @return [String]
  def translate_markdown(markdown)
    raw Govspeak::Document.to_html(markdown, sanitize: false)
  end

  # Date format guidelines: "1 June 2002"
  # @param modules [Array<TrainingModule>]
  # @return [String]
  def completed_modules_table(modules)
    header = ['Module name', 'Date completed', 'Actions']
    rows = modules.map do |mod, timestamp|
      [
        govuk_link_to(mod.title, training_module_path(mod)),
        timestamp.to_date.strftime('%-d %B %Y'),
        govuk_link_to('View certificate', training_module_content_page_path(mod, mod.certificate_page)),
      ]
    end
    govuk_table(rows: [header, *rows], caption: 'Completed modules', first_cell_is_header: true)
  end

  # @return [String]
  def govuk_heading(text, tag: :h1)
    return if text.blank?

    content_tag(tag, class: 'govuk-heading-m') { text }
  end

  # @param icon [String, Symbol] Fontawesome icon name
  # @return [String]
  def icon(icon)
    content_tag(:i, nil, class: "fa-solid fa-3x fa-#{icon}")
  end

  # @return [String]
  def print_button(*additional_classes)
    button = '<button class="govuk-link gem-c-print-link__button" onclick="window.print()" data-module="print-link" >Print this page</button>'.html_safe
    classes = ['gem-c-print-link', 'print-button'] + additional_classes
    content_tag :div, button, class: classes
  end

  # @see ModuleItem.pagination
  # @see Questionnaire.pagination
  #
  # @return [String]
  def page_number(current:, total:)
    return if current.blank?

    content_tag :span, class: 'govuk-caption-l' do
      t('page_number', current: current, total: total)
    end
  end

  # @param success [Boolean]
  # @param score [Integer]
  # @return [String]
  def results_banner(success:, score:)
    state = success ? :pass : :fail
    title = t(".#{state}.heading")
    text = t(".#{state}.text", score: score)

    govuk_notification_banner(title_text: title, text: translate_markdown(text))
  end

  # @return [String]
  def progress_indicator(status, colour)
    govuk_tag(text: t(status, scope: 'module_indicator'), colour: colour)
  end
end
