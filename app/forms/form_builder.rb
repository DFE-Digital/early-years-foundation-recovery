# @see https://govuk-form-builder.netlify.app
#
#
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

  # @return [String]
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
  # @return [String]
  def question_radio_button(option)
    govuk_radio_button :answers,
                       option.id,
                       label: { text: option.label },
                       disabled: option.disabled?,
                       checked: option.checked?
  end

  # @param option [Training::Answer::Option]
  # @option text [String]
  # @option more [Boolean]
  # @return [String]
  def other_radio_button(option, text:, more:)
    govuk_radio_button :answers,
                       option.id,
                       label: { text: option.label },
                       disabled: option.disabled?,
                       checked: option.checked? do
      if more
        govuk_text_area :text_input, label: { text: text }
      else
        govuk_text_field :text_input, label: { text: text }
      end
    end
  end

  # @option checked [Boolean]
  # @option text [String]
  # @return [String]
  def or_radio_button(text:, checked:)
    govuk_radio_button :answers,
                       0,
                       label: { text: text },
                       checked: checked
  end

  # @option checked [Boolean]
  # @option text [String]
  # @return [String]
  def or_checkbox_button(text:, checked:)
    govuk_check_box :answers,
                    0,
                    label: { text: text },
                    checked: checked
  end

  # @param option [Training::Answer::Option]
  # @return [String]
  def question_check_box(option)
    govuk_check_box :answers,
                    option.id,
                    label: { text: option.label },
                    disabled: option.disabled?,
                    checked: option.checked?
  end

  # @param option [Training::Answer::Option]
  # @option text [String]
  # @return [String]
  def other_check_box(option, text:)
    govuk_check_box :answers,
                    option.id,
                    label: { text: option.label },
                    disabled: option.disabled?,
                    checked: option.checked? do
      govuk_text_field :text_input, label: { text: text }
    end
  end

  # @return [String]
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

  # @return [String]
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

  # @return [String]
  def select_trainee_experience
    govuk_collection_radio_buttons :early_years_experience,
                                   Trainee::Experience.all, :id, :name,
                                   legend: { text: I18n.t('register_early_years_experience.label'), class: 'govuk-visually-hidden govuk-!-padding-top-9' },
                                   aria: { label: 'registration early years experience' },
                                   form_group: { classes: %w[data-hj-suppress] }
  end

  # @param field [Symbol]
  # @return [String]
  def opt_in_out(field)
    govuk_collection_radio_buttons field,
                                   FormOption.build(field), :id, :name,
                                   legend: { text: I18n.t(:heading, scope: field) },
                                   hint: { text: I18n.t(:body, scope: field) }
  end
end
