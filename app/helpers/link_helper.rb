module LinkHelper
  # @note Handle active sessions for feature flag Rails.application.gov_one_login?
  # @return [String]
  def destroy_user_session_path
    session[:id_token].present? ? logout_uri.to_s : super
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
        new_training_module_assessment_path(mod.name)
      else
        training_module_page_path(mod.name, content.name)
      end

    [text, path]
  end

  # @return [Boolean]
  def one_off_question?
    always_show_question.eql?(false)
  end

  # @return [String] next page (ends on certificate)
  def link_to_next
    page = content.interruption_page? ? mod.content_start : content.next_item

    if !content.interruption_page? && !content.video_page? && content.next_item.skippable? && current_user.response_for_shared(content.next_item, mod).responded?
      page = page.next_item
    end

    govuk_button_link_to content.next_button_text, training_module_page_path(mod.name, page.name),
                         id: 'next-action',
                         aria: { label: t('pagination.next') }
  end

  # @return [String] previous page or module overview
  def link_to_previous
    previous_content = content.previous_item
    path =
      if content.interruption_page?
        training_module_path(mod.name)
      else
        training_module_page_path(mod.name, previous_content.name)
      end

    if !content.interruption_page? && content.previous_item.skippable? && current_user.response_for_shared(content.previous_item, mod).responded?
      path = training_module_page_path(mod.name, previous_content.previous_item.name)
    end

    style = content.section? && !content.opinion_intro? ? 'section-intro-previous-button' : 'govuk-button--secondary'

    # Check if feedback questions have been skipped
    if content.thankyou? && !current_user.response_for_shared(content.previous_item, mod).responded?
      govuk_button_link_to 'Previous', training_module_page_path(mod.name, mod.opinion_intro_page.name),
                           class: style,
                           aria: { label: t('pagination.previous') }
    else
      govuk_button_link_to 'Previous', path,
                           class: style,
                           aria: { label: t('pagination.previous') }
    end
  end

  # Bottom of my-modules card component
  #
  # @param mod [Training::Module]
  # @return [String, nil]
  def link_to_retake_or_results(mod)
    if Rails.application.migrated_answers?
      return unless assessment_progress_service(mod).graded?
    else
      return unless assessment_progress_service(mod).attempted?
    end

    if assessment_progress_service(mod).failed?
      govuk_link_to 'Retake end of module test', new_training_module_assessment_path(mod.name), no_visited_state: true, class: 'card-link--retake'
    else
      govuk_link_to 'View previous test result', training_module_assessment_path(mod.name, mod.assessment_results_page.name), no_visited_state: true, class: 'card-link--retake'
    end
  end

  # @return [String, nil] thank you page (skips feedback questions)
  def link_to_skip
    return unless content.opinion_intro?

    govuk_link_to 'Skip feedback', training_module_page_path(mod.name, mod.thankyou_page.name)
  end
end
