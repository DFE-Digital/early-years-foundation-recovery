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
  # @param content [Training::Content]
  #
  # @return [String] not_started / started / failed / completed
  def link_to_action(state, content)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_path(content.parent.name)
      else
        training_module_page_path(content.parent.name, content.name)
      end

    govuk_button_link_to text, path, id: 'module-call-to-action'
  end

  # @param content [Training::Content]
  # @return [String] next page (ends on certificate)
  def link_to_next(content)
    if content.next_item.nil? && (Rails.application.preview? || Rails.env.test?)
      text = 'Next page has not been created'
      path = training_module_page_path(content.parent.name, content.name)
    else
      text = content.next_button_text
      path = training_module_page_path(content.parent.name, content.next_item.name)
    end

    govuk_button_link_to text, path, id: 'next-action', aria: { label: 'Go to the next page' }
  end

  # @param content [Training::Content]
  # @return [String] previous page or module overview
  def link_to_previous(content)
    path =
      if content.previous_item
        training_module_page_path(content.parent.name, content.previous_item.name)
      else
        training_module_path(content.parent.name)
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
