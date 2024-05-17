class NotifyMailer < GovukNotifyRails::Mailer
  # @return [Hash<Symbol => String>]
  TEMPLATE_IDS = {
    account_closed: '0a4754ee-6175-444c-98a1-ebef0b14e7f7',
    account_closed_internal: 'a2dba0ef-84f1-4b4d-b50a-ce953050798e',
    complete_registration: 'b960eb6a-d183-484b-ac3b-93ae01b3cee1',
    continue_training: '83dd3dc6-c5de-4e32-a6b4-25c76e805d87',
    new_module: '2352b6ce-a098-47f0-870a-286308b9798f',
    start_training: 'b3c2e4ff-da06-4672-8941-b2f50d37eadc',
  }.freeze

  # @param record [User]
  # @return [Mail::Message]
  def account_closed(record)
    set_template TEMPLATE_IDS[:account_closed]
    set_personalisation(
      name: record.name,
      email: record.email,
    )
    mail(to: record.email)
  end

  # @param record [User]
  # @param user_email_address [String]
  # @return [Mail::Message]
  def account_closed_internal(record, user_email_address)
    set_template TEMPLATE_IDS[:account_closed_internal]
    set_personalisation(
      email: record.email,
      user_email_address: user_email_address,
    )
    mail(to: record.email)
  end

  # @param record [User]
  # @return [Mail::Message]
  def complete_registration(record)
    set_template TEMPLATE_IDS[:complete_registration]
    set_personalisation(
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param record [User]
  # @return [Mail::Message]
  def start_training(record)
    set_template TEMPLATE_IDS[:start_training]
    set_personalisation(
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param record [User]
  # @param mod [Training::Module]
  # @return [Mail::Message]
  def continue_training(record, mod)
    set_template TEMPLATE_IDS[:continue_training]
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param record [User]
  # @param mod [Training::Module]
  # @return [Mail::Message]
  def new_module(record, mod)
    set_template TEMPLATE_IDS[:new_module]
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      mod_criteria: mod.criteria,
      url: root_url,
    )
    mail(to: record.email)
  end
end
