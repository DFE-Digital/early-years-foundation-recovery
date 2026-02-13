module LinkHelper
  # @return [String]
  def destroy_user_session_path
    session[:id_token].present? && !current_user.test_user? ? logout_uri.to_s : super
  end

  # @return [String, nil]
  def back_link
    case params[:controller]
    when %r{training/(modules)}
      govuk_back_link text: 'Back to My modules', href: my_modules_path
    when %r{training/(pages|questions|assessments)}
      govuk_back_link href: training_module_path(mod.name),
                      text: "Back to Module #{mod.position} overview"
    when 'pages', 'settings', 'feedback', %r{registration/*.}, 'close_accounts'
      govuk_back_link href: url_for(:back)
    end
  end

  # @return [String]
  def link_to_cms
    cms = 'https://app.contentful.com'
    space = Rails.application.config.contentful_space
    env = Rails.application.config.contentful_environment
    govuk_link_to 'Edit in Contentful', "#{cms}/spaces/#{space}/environments/#{env}/entries/#{content.id}"
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
    path = content.interruption_page? ? training_module_path(mod.name) : training_module_page_path(mod.name, previous_page.name)

    govuk_button_link_to previous_page.text, path,
                         id: 'previous-action',
                         class: previous_page.style,
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

  # @return [String]
  def link_to_skip_feedback
    govuk_link_to t('links.feedback.skip'), training_module_page_path(mod.name, mod.thankyou_page.name)
  end

  # @return [String]
  def link_to_skip_pre_confidence
    govuk_link_to t('links.confidence.skip'), training_module_page_path(mod.name, mod.content_start.name)
  end

  # @return [NextPageDecorator]
  def next_page
    NextPageDecorator.new(
      user: current_user,
      mod: mod,
      content: content,
      assessment: (mod.is_a?(Training::Module) ? assessment_progress_service(mod) : nil),
    )
  end

  # @return [PreviousPageDecorator]
  def previous_page
    PreviousPageDecorator.new(
      user: current_user,
      mod: mod,
      content: content,
    )
  end
end
