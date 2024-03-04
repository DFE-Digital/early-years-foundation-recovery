class FormBuilder < GOVUKDesignSystemFormBuilder::FormBuilder
  def govuk_text_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
  end

  def govuk_email_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
  end

  def govuk_password_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
  end

  # @param content [Object]
  # @return [String]
  def feedback_question_radio_buttons(content)
    @template.capture do
      content.options.each.with_index(1) do |option, index|
        if content.is_last_option?(index) && content.has_other?
          @template.concat feedback_other_radio_button(content, option)
        else
          @template.concat question_radio_button(option)
        end
      end

      if content.has_hint?
        @template.concat govuk_text_area :text_input, label: { text: content.hint, class: 'govuk-!-font-weight-bold govuk-!-margin-top-8 govuk-!-margin-bottom-4' }
      end
    end
  end

  # @param content [Object]
  # @return [String]
  def feedback_question_check_boxes(content)
    @template.capture do
      content.options.each.with_index(1) do |option, index|
        if content.is_last_option?(index) && content.other.present?
          @template.concat feedback_other_check_box(content, option)
        elsif content.is_last_option?(index) && content.or.present?
          @template.concat @template.content_tag(:div, 'Or', class: 'govuk-checkboxes__divider')
          @template.concat govuk_check_box :answers, 'Or', label: { text: content.or }, link_errors: true
        else
          @template.concat question_check_box(option)
        end
      end
    end
  end

  # @param content [Object]
  # @param option [Object] The content for the 'Other' checkbox option
  # @return [String]
  def feedback_other_check_box(content, option)
    govuk_check_box :answers, option.id, label: { text: 'Other' }, link_errors: true do
      govuk_text_field :text_input, label: { text: content.other }
    end
  end

  # @param content [Object]
  # @param option [Object] The content for the 'Other' radio button option
  # @return [String]
  def feedback_other_radio_button(content, option)
    govuk_radio_button :answers, option.id, label: { text: 'Other' }, link_errors: true do
      govuk_text_field :text_input, label: { text: content.other }
    end
  end

  def terms_and_conditions_check_box
    govuk_check_box :terms_and_conditions_agreed_at,
                    Time.zone.now,
                    nil,
                    multiple: false,
                    link_errors: true,
                    aria: { required: true },
                    label: { text: 'I confirm that I accept the terms and conditions and privacy policy.' }
  end

  # @param option [Training::Answer::Option]
  def question_radio_button(option)
    govuk_radio_button :answers,
                       option.id,
                       label: { text: option.label },
                       link_errors: true,
                       disabled: option.disabled?,
                       checked: option.checked?
  end

  # @param option [Training::Answer::Option]
  def question_check_box(option)
    govuk_check_box :answers,
                    option.id,
                    label: { text: option.label },
                    link_errors: true,
                    disabled: option.disabled?,
                    checked: option.checked?
  end

  def select_trainee_setting
    govuk_collection_select :setting_type_id,
                            Trainee::Setting.all, :name, :title,
                            options: { include_blank: true },
                            label: { text: I18n.t('register_setting.label'), class: 'govuk-visually-hidden' },
                            hint: { text: I18n.t('register_setting.body') },
                            data: { controller: 'autocomplete', 'autocomplete-message-value': I18n.t('register_setting.not_found') },
                            aria: { label: 'registration setting type' },
                            form_group: { classes: %w[data-hj-suppress] }
  end

  def select_trainee_authority
    govuk_collection_select :local_authority,
                            Trainee::Authority.all, :name, :name,
                            options: { include_blank: true },
                            label: { text: I18n.t('register_authority.label'), class: 'govuk-visually-hidden' },
                            hint: { text: I18n.t('register_authority.body') },
                            data: { controller: 'autocomplete', 'autocomplete-message-value': I18n.t('register_authority.not_found') },
                            aria: { label: 'registration local authority' },
                            form_group: { classes: %w[data-hj-suppress] }
  end

  def select_trainee_experience
    govuk_collection_select :early_years_experience,
                            Trainee::Experience.all, :name, :name,
                            label: { text: I18n.t('register_early_years_experience.label'), class: 'govuk-visually-hidden' },
                            aria: { label: 'registration early years experience' },
                            form_group: { classes: %w[data-hj-suppress] }
  end

  def opt_in_out(field)
    govuk_collection_radio_buttons field,
                                   FormOption.build(field), :id, :name,
                                   legend: { text: I18n.t(:heading, scope: field) },
                                   hint: { text: I18n.t(:body, scope: field) }
  end
end
