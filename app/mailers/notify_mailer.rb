class NotifyMailer < GovukNotifyRails::Mailer
  ACCOUNT_CLOSED_TEMPLATE_ID = '0a4754ee-6175-444c-98a1-ebef0b14e7f7'.freeze
  ACCOUNT_CLOSED_INTERNAL_TEMPLATE_ID = 'a2dba0ef-84f1-4b4d-b50a-ce953050798e'.freeze
  ACTIVATION_TEMPLATE_ID = 'd6ab2e3b-923e-429e-abd2-cfe7be0e9193'.freeze
  UNLOCK_TEMPLATE_ID = 'e18e8419-cfcc-4fcb-abdb-84f932f3cf55'.freeze
  COMPLETE_REGISTRATION_TEMPLATE_ID = 'b960eb6a-d183-484b-ac3b-93ae01b3cee1'.freeze
  START_TRAINING_TEMPLATE_ID = 'b3c2e4ff-da06-4672-8941-b2f50d37eadc'.freeze
  CONTINUE_TRAINING_TEMPLATE_ID = '83dd3dc6-c5de-4e32-a6b4-25c76e805d87'.freeze
  NEW_MODULE_TEMPLATE_ID = '2352b6ce-a098-47f0-870a-286308b9798f'.freeze

  include Devise::Controllers::UrlHelpers

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notify_mailer.test_email.subject
  #

  def account_closed(record)
    set_template(ACCOUNT_CLOSED_TEMPLATE_ID)

    set_personalisation(
      name: record.name,
      email: record.email,
    )
    mail(to: record.email)
  end

  def account_closed_internal(record, user_email_address)
    set_template(ACCOUNT_CLOSED_INTERNAL_TEMPLATE_ID)

    set_personalisation(
      email: record.email,
      user_email_address: user_email_address,
    )
    mail(to: record.email)
  end

  # @param [User] record
  def complete_registration(record)
    set_template(COMPLETE_REGISTRATION_TEMPLATE_ID)
    set_personalisation(
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param [User] record
  def start_training(record)
    set_template(START_TRAINING_TEMPLATE_ID)
    set_personalisation(
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param [User] record
  # @param [Training::Module] mod
  def continue_training(record, mod)
    set_template(CONTINUE_TRAINING_TEMPLATE_ID)
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      url: root_url,
    )
    mail(to: record.email)
  end

  # @param [User] record
  # @param [Training::Module] mod
  def new_module(record, mod)
    set_template(NEW_MODULE_TEMPLATE_ID)
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      mod_criteria: mod.criteria,
      url: root_url,
    )
    mail(to: record.email)
  end
end
