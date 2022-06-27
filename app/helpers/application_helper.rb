module ApplicationHelper
  def navigation
    govuk_header(service_name: 'Child development training', classes: 'noprint') do |header|
      header.navigation_item(text: 'Home', href: root_path)
      if user_signed_in?
        header.navigation_item(text: 'My learning', href: my_learning_path)
        header.navigation_item(text: 'My account', href: user_path)
        header.navigation_item(text: 'Sign out', href: destroy_user_session_path, options: { data: { turbo_method: :get } })
      else
        header.navigation_item(text: 'Sign in', href: new_user_session_path)
      end
    end
  end

  def configuration_summary_list
    govuk_summary_list(
      rows: [
        { key: { text: 'Rails version' }, value: { text: Rails.version } },
        { key: { text: 'Ruby version' }, value: { text: RUBY_VERSION } },
        { key: {
          text: 'GOV.UK Frontend',
        },
          value: {
            text: JSON
              .parse(File.read(Rails.root.join('package.json')))
              .dig('dependencies', 'govuk-frontend')
              .tr('^', ''),
          } },
      ],
    )
  end

  # @return [String] next content page or course overview
  def link_to_next_module_item(module_item, link_args = { class: 'govuk-button' })
    if module_item.next_item
      link_to 'Next', training_module_content_page_path(module_item.training_module, module_item.next_item), link_args
    else
      link_to 'Finish', course_overview_path, link_args
    end
  end

  # @return [String] previous content page or module overview
  def link_to_previous_module_item(module_item, link_args = { class: 'govuk-button govuk-button--secondary' })
    link =
      if module_item.previous_item
        training_module_content_page_path(module_item.training_module, module_item.previous_item)
      else
        training_module_path(module_item.training_module)
      end
    link_to 'Previous', link, link_args
  end

  # Date format guidelines: "1 June 2002"
  def completed_modules_table(modules)
    header = ['Module name', 'Date completed', 'Actions']
    rows = modules.map do |mod, timestamp|
      [
        govuk_link_to(mod.title, training_module_path(mod)),
        timestamp.to_date.strftime('%-d %B %Y'),
        govuk_link_to('View certificate', training_module_certificate_path(mod)),
      ]
    end
    govuk_table(rows: [header, *rows], caption: 'Completed modules', first_cell_is_header: true)
  end

  def link_to_retake_quiz(module_item, link_args = { class: 'govuk-button' })
    link_to 'Retake test', training_module_retake_quiz_path(module_item.training_module), link_args
  end

  def link_to_my_learning(module_item, link_args = { class: 'govuk-link, govuk-!-margin-right-4' })
    link_to 'Go to my Learning', course_overview_path, link_args
  end

  def clear_flash
    flash[:alert] = nil
  end

  def answers_checkbox(user_answers, checkbox_value)
    return if !user_answers.present?
    user_answers.include? checkbox_value.to_s
  end

  def disable_checkbox(questionnaire)
    begin
      return if !questionnaire.submitted.present?
      (questionnaire.assessments_type != 'confidence_check')? true : false
    rescue => exception
      true
    end
  end

  
  def incorrect_answers_checkbox(questions_options, user_answers)
    return if !user_answers.present?

    correct_answers = []
    questions_options.each do |q|
      if user_answers.map(&:to_s).include? q[0].to_s
        correct_answers.push(q[1])
      end
    end

    correct_answers.join(', ')
  end

  def link_to_next_module_item_from_controller(module_item)
    if module_item.next_item
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    else
       redirect_to course_overview_path and return
    end
  end
end
