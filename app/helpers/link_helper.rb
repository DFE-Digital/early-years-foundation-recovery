module LinkHelper
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

  # @param state [Symbol]
  # @param mod [Training::Module]
  # @param content [Training::Content]
  #
  # @return [String] not_started / started / failed / completed
  def link_to_action(state, mod, content)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_path(mod.name)
      else
        training_module_page_path(mod.name, content.name)
      end

    govuk_button_link_to text, path, id: 'module-call-to-action'
  end

  # @return [String] next page (ends on certificate)
  def link_to_next
    page = content.interruption_page? ? mod.content_start : content.next_item

    govuk_button_link_to content.next_button_text, training_module_page_path(mod.name, page.name),
                         id: 'next-action',
                         aria: { label: 'Go to the next page' }
  end

  # @return [String] previous page or module overview
  def link_to_previous
    path =
      if content.interruption_page?
        training_module_path(mod.name)
      else
        training_module_page_path(mod.name, content.previous_item.name)
      end

    govuk_button_link_to 'Previous', path,
                         class: 'govuk-button--secondary',
                         aria: { label: 'Go to the previous page' }
  end

  # Bottom of my-modules card component
  #
  # @param mod [Training::Module]
  # @return [String, nil]
  def link_to_retake_or_results(mod)
    return unless assessment_progress_service(mod).attempted?

    if assessment_progress_service(mod).failed?
      govuk_link_to 'Retake end of module test', new_training_module_assessment_path(mod.name), no_visited_state: true, class: 'card-link--retake'
    else
      govuk_link_to 'View previous test result', training_module_assessment_path(mod.name, mod.assessment_results_page.name)
    end
  end
end
