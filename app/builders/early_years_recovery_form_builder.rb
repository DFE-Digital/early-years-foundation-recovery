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
end
