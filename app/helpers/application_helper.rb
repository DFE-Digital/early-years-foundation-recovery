module ApplicationHelper
  # @return [String]
  def navigation
    govuk_header(classes: 'noprint') do |header|
      header.navigation_item(text: 'Home', href: root_path)
      header.custom_logo { custom_logo }
      if user_signed_in?
        header.navigation_item(text: 'My modules', href: my_modules_path)
        header.navigation_item(text: 'Learning log', href: user_notes_path) if current_user.course_started?
        header.navigation_item(text: 'My account', href: user_path)
        header.navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :get } })
      else
        header.navigation_item(text: 'Sign in', href: new_user_session_path)
      end
    end
  end

  # @return [String]
  def custom_logo
    [
      image_tag('crest.png', alt: 'Department for Education homepage', class: 'govuk-header__logotype-crown-fallback-image'),
      content_tag(:span, 'Department for Education | ', class: 'govuk-header__logotype-text'),
      content_tag(:span, service_name, class: 'govuk-header__product-name'),
    ].join.html_safe
  end

  # @return [String]
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

  # @param mod [TrainingModule]
  # @return [SummativeAssessmentProgress]
  def assessment_progress(mod)
    SummativeAssessmentProgress.new(user: current_user, mod: mod)
  end

  # @param mod [Training::Module]
  # @return [ContentfulModuleProgress]
  def cms_module_progress(mod)
    ContentfulModuleProgress.new(user: current_user, mod: mod)
  end

  # @param mod [TrainingModule]
  # @return [ModuleProgress]
  def module_progress(mod)
    ModuleProgress.new(user: current_user, mod: mod)
  end

  # @return [Boolean]
  def track_analytics?
    cookies[:track_analytics] == 'true'
  end

  # @param page [nil, ::ModuleItem, ::Training::Page, ::Page]
  # @return [String]
  def html_title(page)
    # ::ModuleItem or ::Training::Page
    module_title = page.parent.title if page.respond_to?(:parent)
    # ::Training::Page, ::Page vs ::ModuleItem
    default = page.model.heading if page

    # I18n
    custom = params.permit('controller', 'action', 'id').values.join('.')
    page_title = t(custom, scope: 'html_title', default: default)

    [
      service_name,
      module_title,
      page_title,
    ].compact.join(' : ')
  end

  # @return [String]
  def calculate_module_state
    CalculateModuleState.new(user: current_user).call
  end
end
