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
end
