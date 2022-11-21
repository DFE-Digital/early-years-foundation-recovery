class NotifyMailer < GovukNotifyRails::Mailer
  ACTIVATION_TEMPLATE_ID = 'd6ab2e3b-923e-429e-abd2-cfe7be0e9193'.freeze
  EMAIL_CHANGED_TEMPLATE_ID = 'c1228884-6621-4a1e-9606-b219bedb677f'.freeze
  EMAIL_CONFIRMATION_TEMPLATE_ID = 'a2412831-e253-4df4-a8f1-19332eed4cef'.freeze
  EMAIL_TAKEN_TEMPLATE_ID = '857dc6d0-7179-48bf-8079-916fedb43528'.freeze
  PASSWORD_CHANGED_TEMPLATE_ID = 'f77e1eba-3fa8-45ae-9cec-a4cc54633395'.freeze
  RESET_PASSWORD_TEMPLATE_ID = 'ad77aab8-d903-4f77-b074-a16c2658ca79'.freeze
  UNLOCK_TEMPLATE_ID = 'e18e8419-cfcc-4fcb-abdb-84f932f3cf55'.freeze

  include Devise::Controllers::UrlHelpers

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notify_mailer.test_email.subject
  #

  def activation_instructions(record, token, _opts = {})
    set_template(ACTIVATION_TEMPLATE_ID)

    set_personalisation(
      confirmation_url: confirmation_url(record, confirmation_token: token),
    )
    mail(to: record.unconfirmed_email? ? record.unconfirmed_email : record.email)
  end

  def email_changed(record, _opts = {})
    set_template(EMAIL_CHANGED_TEMPLATE_ID)

    set_personalisation(
      is_unconfirmed_email: record.unconfirmed_email? ? 'Yes' : 'No',
      is_not_unconfirmed_email: record.unconfirmed_email? ? 'No' : 'Yes',
      email: record.unconfirmed_email? ? record.unconfirmed_email : record.email,
    )
    mail(to: record.email)
  end

  def email_confirmation_instructions(record, token, _opts = {})
    set_template(EMAIL_CONFIRMATION_TEMPLATE_ID)

    set_personalisation(
      confirmation_url: confirmation_url(record, confirmation_token: token),
    )
    mail(to: record.unconfirmed_email? ? record.unconfirmed_email : record.email)
  end

  def email_taken(record)
    set_template(EMAIL_TAKEN_TEMPLATE_ID)

    set_personalisation(
      name: record.name,
      email: record.email,
      reset_password_url: new_user_password_url,
    )
    mail(to: record.email)
  end

  def password_change(record, _opts = {})
    set_template(PASSWORD_CHANGED_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Password changed',
      name: record.name,
    )
    mail(to: record.email)
  end

  def reset_password_instructions(record, token, _opts = {})
    set_template(RESET_PASSWORD_TEMPLATE_ID)

    set_personalisation(
      name: record.name,
      edit_password_url: edit_password_url(record, reset_password_token: token),
    )
    mail(to: record.email)
  end

  def unlock_instructions(record, token, _opts = {})
    set_template(UNLOCK_TEMPLATE_ID)

    set_personalisation(
      name: record.name,
      unlock_url: unlock_url(record, unlock_token: token),
    )
    mail(to: record.email)
  end
end
