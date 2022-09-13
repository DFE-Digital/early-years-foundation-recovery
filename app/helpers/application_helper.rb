module ApplicationHelper
  # @return [String]
  def navigation
    govuk_header(service_name: 'Child development training', classes: 'noprint') do |header|
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

  # @param mod [TrainingModule]
  # @return [ModuleProgress]
  def module_progress(mod)
    ModuleProgress.new(user: current_user, mod: mod)
  end

  def track_analytics?
    cookies[:track_analytics] == 'true'
  end

  def calculate_module_state
    CalculateModuleState.new(user: current_user).call
  end

  # @return [String]
  def html_title(module_item)
    site_title = 'Child development training'
    module_title = module_item&.parent&.title
    title = t(params.permit('controller', 'action', 'id').values.join('.'), scope: 'html_title', default: module_item&.model&.heading)
    [
      site_title,
      module_title,
      title,
    ].compact.join(' : ')
  end
end
