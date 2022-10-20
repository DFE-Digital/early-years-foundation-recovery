module LinkHelper
  # @return [String] next content page or course overview
  # @param item [ModuleItem]
  def link_to_next_module_item(item)
    mod = item.training_module
    if item.next_item
      govuk_button_link_to item.next_button_text, training_module_content_page_path(mod, item.next_item)
    else
      govuk_button_link_to 'Finish', course_overview_path
    end
  end

  # @return [String] previous content page or module overview
  # @param item [ModuleItem]
  def link_to_previous_module_item(item)
    mod = item.training_module
    path =
      if item.previous_item
        training_module_content_page_path(mod, item.previous_item)
      else
        training_module_path(mod)
      end
    govuk_button_link_to 'Previous', path, class: 'govuk-button--secondary'
  end

  # @param state [Symbol]
  # @param mod [TrainingModule]
  # @param item [ModuleItem]
  #
  # @return [String] not_started / started / failed / completed
  def link_to_action(state, mod, item)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_result_path(mod)
      else
        training_module_content_page_path(mod, item)
      end
    govuk_button_link_to text, path
  end

  # @param mod [TrainingModule]
  # @return [String, nil]
  def link_to_retake_or_results(mod)
    return unless assessment_progress(mod).attempted?

    if assessment_progress(mod).failed?
      govuk_link_to 'Retake end of module test', new_training_module_assessment_result_path(mod)
    else
      govuk_link_to 'View previous test result', training_module_assessment_result_path(mod, mod.assessment_results_page)
    end
  end
end
