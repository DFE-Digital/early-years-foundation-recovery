module LinkHelper
  # @return [String] next content page (ends on certificate)
  # @param item [ModuleItem]
  def link_to_next_module_item(item)
    text = item.next_button_text
    path = training_module_page_path(item.training_module, item.next_item)

    govuk_button_link_to text, path, id: 'next_action', aria: { label: 'Go to the next page' }
  end

  # @return [String] previous content page or module overview
  # @param item [ModuleItem]
  def link_to_previous_module_item(item)
    path =
      if item.previous_item
        training_module_page_path(item.training_module, item.previous_item)
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
  def link_to_action(state, item)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_result_path(item.training_module)
      else
        training_module_page_path(item.training_module, item)
      end

    govuk_button_link_to text, path, id: 'module_call_to_action'
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

  # @return [String]
  def back_link
    if %w[training/pages content_pages questionnaires assessment_results].include?(params[:controller])
      govuk_back_link(
        href: training_module_path(params[:training_module_id]),
        text: "Back to Module #{training_module.position} overview",
      )
    elsif params[:controller].eql?('contentful/static')
      govuk_back_link href: url_for(:back)
    end
  end

  # CMS ------------------------------------------------------------------------

  # @param state [Symbol]
  # @param content [Module::Content]
  #
  # @return [String] not_started / started / failed / completed
  def cms_link_to_action(state, content)
    text = t(state, scope: 'module_call_to_action')
    path =
      if state.eql?(:failed)
        new_training_module_assessment_result_path(content.parent.name)
      else
        training_module_page_path(content.parent.name, content.name)
      end

    govuk_button_link_to text, path
  end

  # @param content [Module::Content]
  # @return [String] next content page (ends on certificate)
  def cms_link_to_next_module_item(content)
    text = content.next_button_text
    path = training_module_page_path(content.parent.name, content.next_item.name)

    govuk_button_link_to text, path, aria: { label: 'Go to the next page' }
  end

  # @param content [Module::Content]
  # @return [String] previous content page or module overview
  def cms_link_to_previous_module_item(content)
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
end
