module LinkHelper
  # @return [String] next content page (ends on certificate)
  # @param item [ModuleItem]
  def link_to_next_module_item(item)
    path = training_module_content_page_path(item.training_module, item.next_item)
    # NB: WIP
    # - Next (content page)
    # - Save and continue (question page) not used by this method because it is a form
    # - Start test (assessment intro)
    # - Finish test (last question)
    # - Finish (penultimate page)
    text = item.next_button_text

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
    # TODO: maybe label the CTA for accessibility?
    # , aria: { label: 'Descriptive call to action' }
  end

  # Bottom of my-modules card component
  #
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
