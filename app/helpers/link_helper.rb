module LinkHelper
  # @return [String]
  def destroy_user_session_path
    session[:id_token].present? && !current_user.test_user? ? logout_uri.to_s : super
  end

  # OPTIMIZE: use this helper for all back link logic and consistent location
  #
  # @return [String, nil]
  def back_link
    case params[:controller]
    when 'training/pages', 'training/questions', 'training/assessments'
      govuk_back_link href: training_module_path(mod.name),
                      text: "Back to Module #{mod.position} overview"
    when 'settings', 'pages'
      govuk_back_link href: url_for(:back)
    end
  end

  # @return [Array<String>]
  def link_to_action
    state, content = module_progress.call_to_action
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        training_module_page_path(mod.name, mod.assessment_intro_page.name)
      else
        training_module_page_path(mod.name, content.name)
      end

    [text, path]
  end

  # @return [String] next page (ends on certificate)
  def link_to_next
    govuk_button_link_to next_page.text, training_module_page_path(mod.name, next_page.name),
                         id: 'next-action',
                         aria: { label: t('pagination.next') }
  end

  # @return [String] previous page or module overview
  def link_to_previous
    path =
      if content.interruption_page?
        training_module_path(mod.name)
      else
        training_module_page_path(mod.name, content.previous_item.name)
      end

    style = content.section? ? 'section-intro-previous-button' : 'govuk-button--secondary'

    govuk_button_link_to 'Previous', path,
                         class: style,
                         aria: { label: t('pagination.previous') }
  end

  # Bottom of my-modules card component
  #
  # @param mod [Training::Module]
  # @return [String, nil]
  def link_to_retake_or_results(mod)
    return unless assessment_progress_service(mod).graded?

    if assessment_progress_service(mod).failed?
      govuk_link_to 'Retake end of module test', training_module_page_path(mod.name, mod.assessment_intro_page.name), no_visited_state: true, class: 'card-link--retake'
    else
      govuk_link_to 'View previous test result', training_module_assessment_path(mod.name, mod.assessment_results_page.name), no_visited_state: true, class: 'card-link--retake'
    end
  end

  # @return [NextPageDecorator]
  def next_page
    NextPageDecorator.new(
      user: current_user,
      mod: mod,
      content: content,
      assessment: assessment_progress_service(mod),
    )
  end
end
