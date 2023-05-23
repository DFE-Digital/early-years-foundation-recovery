module ApplicationHelper
  # @return [String]
  def navigation
    govuk_header(classes: 'noprint') do |header|
      header.with_navigation_item(text: 'Home', href: root_path)
      header.with_custom_logo { custom_logo }
      if user_signed_in?
        header.with_navigation_item(text: 'My modules', href: my_modules_path)
        header.with_navigation_item(text: 'Learning log', href: user_notes_path) if current_user.course_started?
        header.with_navigation_item(text: 'My account', href: user_path)
        header.with_navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :get } })
      else
        header.with_navigation_item(text: 'Sign in', href: new_user_session_path)
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

  CONFIG_SUMMARY = [
    ['Rails version', Rails.version],
    ['Ruby version', RUBY_VERSION],
    ['GOV.UK Frontend', JSON.parse(File.read(Rails.root.join('package.json'))).dig('dependencies', 'govuk-frontend').tr('^', '')],
  ].freeze

  # @return [String]
  def configuration_summary_list
    rows =
      CONFIG_SUMMARY.map do |key, value|
        { key: { text: key }, value: { text: value } }
      end
    govuk_summary_list(rows: rows)
  end

  # @note deprecate
  # @param mod [TrainingModule]
  # @return [SummativeAssessmentProgress]
  def assessment_progress(mod)
    SummativeAssessmentProgress.new(user: current_user, mod: mod)
  end

  # @note deprecate
  # @param mod [TrainingModule]
  # @return [ModuleProgress]
  def module_progress(mod)
    ModuleProgress.new(user: current_user, mod: mod)
  end

  # @param mod [Training::Module]
  # @return [ContentfulAssessmentProgress]
  def cms_assessment_progress(mod)
    ContentfulAssessmentProgress.new(user: current_user, mod: mod)
  end

  # @param mod [Training::Module]
  # @return [ContentfulModuleProgress]
  def cms_module_progress(mod)
    ContentfulModuleProgress.new(user: current_user, mod: mod)
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
    default =
      if page.is_a?(::ModuleItem)
        page.model.heading
      elsif page.is_a?(::Training::Question)
        page.name
      elsif page.present?
        # ::Training::Page/Video, ::Page
        page.heading
      end

    # I18n
    custom = params.permit('controller', 'action', 'id').values.join('.')
    page_title = t(custom, scope: 'html_title', default: default)

    [service_name, module_title, page_title].compact.join(' : ')
  end

  # @return [String]
  def calculate_module_state
    CalculateModuleState.new(user: current_user).call
  end
end
