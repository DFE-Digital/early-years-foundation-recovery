module ContentHelper
        # @param markdown [String]
        # @return [String]
        # def m(markdown)
        def m(key, headings_start_with: 'l', **args)
          # raw CustomMarkdown.render(markdown.to_s, filter_html: false)

          if I18n.exists?(key)
            raw CustomMarkdown.render t(key, **args), headings_start_with: headings_start_with, filter_html: false
          else
            raw CustomMarkdown.render(key.to_s, filter_html: false)
          end
        rescue Contentful::Error
          raw CustomMarkdown.render(key.to_s, filter_html: false)
        end

        # GDS formatted markdown as HTML
        # @param markdown [String]
        # @return [String]
        def translate_markdown(markdown)
          m(markdown)
        end

        # @param key [String]
        # @param args [Hash]
        # @return [String]
        def content_resource(key, headings_start_with: 'l', **args) # knocks the size down because these are commonly smaller snippets
          # raw GovukMarkdown.render t(key, **args), headings_start_with: headings_start_with
          m(key, headings_start_with: headings_start_with, **args)
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
    image_tag mod.thumbnail_url, width: 200, alt: '', title: ''
  end

  # @param icon [String, Symbol] Fontawesome icon name
  # @param size [Integer] Icon scale factor
  # @return [String]
  def icon(icon, size: 2, **)
    content_tag :i, nil,
                class: "fa-solid fa-#{size}x fa-#{icon} icon",
                aria: { label: "#{icon} icon" }
  end

  # @return [String]
  def print_button(*additional_classes)
    button = '<button class="govuk-link gem-c-print-link__button" onclick="window.print()" data-module="print-link" >Print this page</button>'.html_safe
    classes = ['gem-c-print-link', 'print-button'] + additional_classes
    content_tag :div, button, class: classes
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

  # replace with form builder fields
  # @yield [Array]
  def opt_in_out(type)
    yield [
      [
        OpenStruct.new(id: true, name: t(:opt_in, scope: type)),
        OpenStruct.new(id: false, name: t(:opt_out, scope: type)),
      ],
      t(:heading, scope: type),
      translate_markdown(t(:body, scope: type)),
    ]
  end

  # @yield [String]
  def password_complexity
    t(:password_complexity, length: User.password_length.first)
  end
end
