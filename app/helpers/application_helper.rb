module ApplicationHelper
  def navigation
    govuk_header(service_name: 'Early Years Foundation') do |header|
      header.navigation_item(text: 'Home', href: root_path)
      if user_signed_in?
        header.navigation_item(text: 'My learning', href: my_learning_path)
        header.navigation_item(text: 'My account', href: user_path)
        header.navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :get } })
      else
        header.navigation_item(text: 'Sign in', href: new_user_session_path)
      end
    end
  end

  def configuration_summary_list
    govuk_summary_list(
      rows: [
        { key: { text: 'Rails version' }, value: { text: Rails.version } },
        { key: { text: 'Ruby version' }, value: { text: RUBY_VERSION } },
        { key: {
          text: 'GOV.UK Frontend',
        },
          value: {
            text: JSON
              .parse(File.read(Rails.root.join('package.json')))
              .dig('dependencies', 'govuk-frontend')
              .tr('^', ''),
          } },
      ],
    )
  end

  # @return [String] next content page or course overview
  def link_to_next_module_item(module_item, link_args = { class: 'govuk-button' })
    if module_item.next_item
      link_to 'Next', training_module_content_page_path(module_item.training_module, module_item.next_item), link_args
    else
      link_to 'Finish', course_overview_path, link_args
    end
  end

  # @return [String] previous content page or module overview
  def link_to_previous_module_item(module_item, link_args = { class: 'govuk-button govuk-button--secondary' })
    link =
      if module_item.previous_item
        training_module_content_page_path(module_item.training_module, module_item.previous_item)
      else
        training_module_path(module_item.training_module)
      end
    link_to 'Previous', link, link_args
  end

  def completed_modules_table(modules)
    header = ['Module name', 'Date completed', 'Actions']
    rows = modules.map do |mod, timestamp|
      [
        govuk_link_to(mod.title, training_module_content_pages_path(mod)),
        timestamp.to_date.to_formatted_s(:rfc822),
        govuk_link_to('View certificate', '#'),
      ]
    end
    govuk_table(rows: [header, *rows], caption: 'Completed modules', first_cell_is_header: true)
  end

  def link_to_retake_quiz(module_item, link_args = { class: 'govuk-button' })
    link_to 'Retake quiz', training_modules_path, link_args
  end

  def link_to_my_learning(module_item, link_args = { class: 'govuk-link, govuk-!-margin-right-4' })
    link_to 'Go to my Learning', training_modules_path, link_args
  end

  def clear_flash
    flash[:alert] = nil
  end
end
