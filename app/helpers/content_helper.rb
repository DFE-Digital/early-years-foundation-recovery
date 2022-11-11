module ContentHelper
  # GDS formatted markdown as HTML
  # @param markdown [String]
  # @return [String]
  def translate_markdown(markdown)
    raw Govspeak::Document.to_html(markdown, sanitize: false)
  end

  # Date format guidelines: "1 June 2002"
  # @return [String]
  def completed_modules_table
    mods = current_user.course.completed_modules
    header = ['Module name', 'Date completed', 'Actions']
    rows = mods.map do |mod, timestamp|
      [
        govuk_link_to(mod.title, training_module_path(mod)),
        timestamp.to_date.strftime('%-d %B %Y'),
        govuk_link_to('View certificate', training_module_content_page_path(mod, mod.certificate_page)),
      ]
    end

    govuk_table(rows: [header, *rows], caption: 'Completed modules')
  end

  # @param mod [TrainingModule]
  # @return [String]
  def training_module_image(mod)
    image_tag image_path(mod.thumbnail), class: 'full-width-img', width: 200, alt: '', title: ''
  end

  # @param icon [String, Symbol] Fontawesome icon name
  # @param size [Integer] Icon scale factor
  # @return [String]
  def icon(icon, size: 2, **)
    content_tag :i, nil,
                class: "fa-solid fa-#{size}x fa-#{icon} icon",
                'aria-describedby': "#{icon} icon"
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
  # @return [String, nil]
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

  # @param status [String, Symbol]
  # @param colour [String]
  # @return [String]
  def progress_indicator(status, colour)
    govuk_tag(text: t(status, scope: 'module_indicator'), colour: colour)
  end

  def service_name
    Rails.configuration.service_name
  end
end
