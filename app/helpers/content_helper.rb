module ContentHelper
  # @see [CustomMarkdown]
  # @param key [String]
  # @return [String]
  def m(key, headings_start_with: 'l', **args)
    markdown = I18n.exists?(key, scope: args[:scope]) ? t(key, **args) : key.to_s

    CustomMarkdown.render(markdown, headings_start_with: headings_start_with, filter_html: false).html_safe
  rescue Contentful::Error
    CustomMarkdown.render(key).html_safe
  end

  # Date format guidelines: "1 June 2002"
  # @return [String]
  def completed_modules_table
    mods = current_user.course.completed_modules
    header = ['Module name', 'Date completed', 'Actions']
    rows = mods.map do |mod, timestamp|
      [
        govuk_link_to(mod.title, training_module_path(mod.name)),
        timestamp.to_date.strftime('%-d %B %Y'),
        govuk_link_to('View certificate', training_module_page_path(mod.name, mod.certificate_page.name)),
      ]
    end

    govuk_table(rows: [header, *rows], caption: 'Completed modules')
  end

  # @param mod [Training::Module]
  # @return [String]
  def training_module_image(mod)
    image_tag mod.thumbnail_url, alt: '', title: ''
  end

  # @param icon [String, Symbol] Fontawesome icon name
  # @param size [Integer] Icon scale factor
  # @return [String]
  def icon(icon, size: 2, **)
    content_tag :i, nil,
                class: "fa-solid fa-#{size}x fa-#{icon} icon",
                aria: { label: "#{icon} icon" }
  end

  # @param success [Boolean]
  # @param score [Integer]
  # @return [String]
  def results_banner(success:, score:)
    state = success ? :pass : :fail
    title = t(".#{state}.heading")
    text = t(".#{state}.text", score: score)

    govuk_notification_banner(title_text: title, text: m(text))
  end

  # @param status [String, Symbol]
  # @return [String]
  def progress_indicator(status)
    colour =
      case status
      when :completed then nil
      when :not_started then 'grey'
      when :started then 'yellow'
      end

    govuk_tag(text: t(status, scope: 'module_indicator'), colour: colour)
  end

  # @return [String]
  def service_name
    Rails.configuration.service_name
  end

  # TODO: replace with form builder fields, Replace Openstruct with DATA
  #
  # @yield [Array] options / legend / hint
  def opt_in_out(type)
    yield [
      [
        OpenStruct.new(id: true, name: t(:opt_in, scope: type)),
        OpenStruct.new(id: false, name: t(:opt_out, scope: type)),
      ],
      t(:heading, scope: type),
      t(:body, scope: type),
    ]
  end

  # @yield [String]
  def password_complexity
    t('password_complexity', length: User.password_length.first)
  end
end
