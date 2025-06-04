module ApplicationHelper
  CONFIG_SUMMARY = [
    ['Rails version', Rails.version],
    ['Ruby version', RUBY_VERSION],
    ['GOV.UK Frontend', JSON.parse(File.read(Rails.root.join('package.json'))).dig('dependencies', 'govuk-frontend').tr('^', '')],
  ].freeze

  # @return [String]
  def navigation
    render(HeaderComponent.new(service_name: service_name, classes: 'dfe-header noprint', navigation_label: 'Primary navigation')) do |header|
      header.with_navigation_item(text: 'Home', href: root_path, classes: %w[dfe-header__navigation-item])
      if user_signed_in?
        header.with_action_link(text: t('my_account.title'), href: user_path, options: { inverse: true })
        header.with_action_link(text: 'Sign out', href: destroy_user_session_path, options: { id: 'sign-out-desktop', data: { turbo_method: :get }, inverse: true })
        header.with_navigation_item(text: t('my_learning.title'), href: my_modules_path, classes: %w[dfe-header__navigation-item])
        header.with_navigation_item(text: t('my_learning_log.title'), href: user_notes_path, classes: %w[dfe-header__navigation-items]) if current_user.course_started?
      else
        header.with_action_link(text: t('account_login.title'), href: new_user_session_path, options: { inverse: true })
        header.with_navigation_item(text: t('account_login.title'), href: new_user_session_path, classes: %w[dfe-header__navigation-item dfe-header-f-mob])
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
  # TODO: optimise this method is called multiple times per module, consider caching/grouping
  def module_progress_service(mod)
    user_module_events = current_user.events.where_properties(training_module_id: mod.name)
    ModuleProgress.new(user: current_user, mod: mod, user_module_events: user_module_events)
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

  # @return [Training::Question] feedback skippable
  def user_research_question
    Course.config.feedback.find(&:skippable?)
  end
end
