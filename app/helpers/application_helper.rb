module ApplicationHelper
  def navigation
    govuk_header(service_name: 'Early Years Foundation') do |header|
      header.navigation_item(text: 'Home', href: root_path)
      if user_signed_in?
        header.navigation_item(text: 'Account', href: user_path)
        header.navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :delete } })
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

  def link_to_next_module_item(module_item, link_args = { class: 'govuk-button' })
    if module_item.next_item
      link_to 'Next', training_module_content_page_path(module_item.training_module, module_item.next_item), link_args
    else
      link_to 'Finish', training_modules_path, link_args
    end
  end

  def link_to_previous_module_item(module_item, link_args = {})
    link =
      if module_item.previous_item
        training_module_content_page_path(module_item.training_module, module_item.previous_item)
      else
        training_modules_path
      end
    link_to 'Previous', link, link_args
  end
end
