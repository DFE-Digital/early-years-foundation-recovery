module ApplicationHelper
  CONFIG_SUMMARY = [
    ['Rails version', Rails.version],
    ['Ruby version', RUBY_VERSION],
    ['GOV.UK Frontend', JSON.parse(File.read(Rails.root.join('package.json'))).dig('dependencies', 'govuk-frontend').tr('^', '')],
  ].freeze

  # @return [String]
  def navigation
    render(HeaderComponent.new(classes: 'dfe-header noprint', container_classes: %w[dfe-header-f-header-flex], navigation_label: 'Primary navigation')) do |header|
      header.with_navigation_item(text: 'Home', href: root_path, classes: %w[dfe-header__navigation-item])
      if user_signed_in?
        header.with_action_link(text: 'My Account', href: user_path, options: { inverse: true })
        header.with_action_link(text: 'Sign out', href: destroy_user_session_path, options: { id: 'sign-out-desktop', data: { turbo_method: :get }, inverse: true })
        header.with_navigation_item(text: 'My modules', href: my_modules_path, classes: %w[dfe-header__navigation-item])
        header.with_navigation_item(text: 'Learning log', href: user_notes_path, classes: %w[dfe-header__navigation-items]) if current_user.course_started?
        header.with_navigation_item(text: 'My account', href: user_path, classes: %w[dfe-header__navigation-item dfe-header-f-mob])
        header.with_navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :get } }, classes: %w[dfe-header__navigation-item dfe-header-f-mob], html_attributes: { id: 'sign-out-f-mob' })
      else
        header.with_action_link(text: 'Sign in', href: new_user_session_path, options: { inverse: true })
        header.with_navigation_item(text: 'Sign in', href: new_user_session_path, classes: %w[dfe-header__navigation-item dfe-header-f-mob])
      end
    end
  end

  # @return [String]
  def configuration_summary_list
    rows =
      CONFIG_SUMMARY.map do |key, value|
        { key: { text: key }, value: { text: value } }
      end
    govuk_summary_list(rows: rows)
  end

  # @param mod [Training::Module]
  # @return [AssessmentProgress]
  def assessment_progress_service(mod)
    AssessmentProgress.new(user: current_user, mod: mod)
  end

  # @param mod [Training::Module]
  # @return [ModuleProgress]
  def module_progress_service(mod)
    ModuleProgress.new(user: current_user, mod: mod)
  end

  # @return [Boolean]
  def track_analytics?
    cookies[:track_analytics] == 'true'
  end

  # @param parts [Array<String>]
  # @return [String]
  def html_title(*parts)
    [service_name, *parts].join(' : ')
  end

  # @return [String]
  def calculate_module_state
    CalculateModuleState.new(user: current_user).call
  end

  # @return [String]
  def destroy_user_session_path
    if Rails.application.gov_one_login? && session[:id_token].present?
      logout_uri.to_s
    else
      super
    end
  end
end
