class EarlyYearsRecoveryFormBuilder < GOVUKDesignSystemFormBuilder::FormBuilder
  def govuk_text_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
  end

  def govuk_email_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
  end

  def govuk_password_field(attribute_name, options = {})
    super(attribute_name, **options.reverse_merge(width: 'two-thirds'))
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
                            data: { controller: 'autocomplete', 'autocomplete-message-value': I18n.t('register_setting.not_found') },
                            aria: { label: 'registration setting type' },
                            form_group: { classes: %w[data-hj-suppress] }
  end

  def select_trainee_authority
    govuk_collection_select :local_authority,
                            Trainee::Authority.all, :name, :name,
                            options: { include_blank: true },
                            label: { text: I18n.t('register_authority.label'), class: 'govuk-visually-hidden' },
                            data: { controller: 'autocomplete', 'autocomplete-message-value': I18n.t('register_authority.not_found') },
                            aria: { label: 'registration local authority' },
                            form_group: { classes: %w[data-hj-suppress] }
  end
end
