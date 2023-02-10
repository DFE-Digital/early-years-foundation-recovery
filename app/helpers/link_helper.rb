module LinkHelper
  # @return [String] next content page (ends on certificate)
  # @param item [ModuleItem]
  def link_to_next_module_item(item)
    text = item.next_button_text
    path = training_module_content_page_path(item.training_module, item.next_item)

    govuk_button_link_to text, path, aria: { label: 'Go to the next page' }
  end

  # @return [String] previous content page or module overview
  # @param item [ModuleItem]
  def link_to_previous_module_item(item)
    path =
      if item.previous_item
        training_module_content_page_path(item.training_module, item.previous_item)
      else
        training_module_path(item.training_module)
      end

    govuk_button_link_to 'Previous', path,
                         class: 'govuk-button--secondary',
                         aria: { label: 'Go to the previous page' }
  end

  # @param state [Symbol]
  # @param item [ModuleItem]
  #
  # @return [String] not_started / started / failed / completed
  # def link_to_action(state, mod, item)
  def link_to_action(state, item)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_result_path(item.training_module)
      else
        training_module_content_page_path(item.training_module, item)
      end

    govuk_button_link_to text, path
  end

  # Bottom of my-modules card component
  #
  # @param mod [TrainingModule]
  # @return [String, nil]
  def link_to_retake_or_results(mod)
    return unless assessment_progress(mod).attempted?

    if assessment_progress(mod).failed?
      govuk_link_to 'Retake end of module test', new_training_module_assessment_result_path(mod), no_visited_state: true, class: 'card-link--retake'
    else
      govuk_link_to 'View previous test result', training_module_assessment_result_path(mod, mod.assessment_results_page)
    end
  end

  def back_link
    if %w[content_pages questionnaires assessment_results].include? params[:controller]
      govuk_back_link(
        href: training_module_path(params[:training_module_id]),
        text: "Back to Module #{training_module.id} overview",
      )
    elsif %w[contentful/static settings].include? params[:controller]
      govuk_back_link href: url_for(:back)
    end
  end
end
