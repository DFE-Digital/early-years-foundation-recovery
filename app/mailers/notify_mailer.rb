class NotifyMailer < GovukNotifyRails::Mailer
  BLANK_TEMPLATE_ID="36555d23-b0e0-4c10-9b85-9c79c98eb1fe".freeze
  CONFIRMATION_TEMPLATE_ID="a44bc231-d779-41d8-a5e0-180497dfa711".freeze
  RESET_PASSWORD_TEMPLATE_ID="ad77aab8-d903-4f77-b074-a16c2658ca79".freeze
  UNLOCK_TEMPLATE_ID="e18e8419-cfcc-4fcb-abdb-84f932f3cf55".freeze
  PASSWORD_CHANGED_TEMPLATE_ID="f77e1eba-3fa8-45ae-9cec-a4cc54633395".freeze
  EMAIL_CHANGED_TEMPLATE_ID="c1228884-6621-4a1e-9606-b219bedb677f".freeze

  include Devise::Controllers::UrlHelpers

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notify_mailer.test_email.subject
  #
  def test_email
    set_template(BLANK_TEMPLATE_ID)
    @greeting = "Hi"

    set_personalisation(
      subject: 'This is just a test',
      name: "Brett McHargue",
      body: "this is the body?"
    )
    mail to: "brett.mchargue@education.gov.uk"
  end

  def confirmation_instructions(record, token, _opts = {})
    set_template(CONFIRMATION_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Confirm account',
      name: record.name,
      confirmation_url: confirmation_url(record, confirmation_token: token)
    )
    mail(to: record.email)
  end

  def reset_password_instructions(record, token, _opts = {})
    set_template(RESET_PASSWORD_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Reset password',
      name: record.name,
      edit_password_url: edit_password_url(record, reset_password_token: token)
    )
    mail(to: record.email)
  end
  
  def unlock_instructions(record, token, _opts = {})
    set_template(UNLOCK_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Unlock account',
      name: record.name,
      unlock_url: unlock_url(record, unlock_token: token)
    )
    mail(to: record.email)
  end
  
  def password_change(record, _opts = {})
    set_template(PASSWORD_CHANGED_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Password changed',
      name: record.name
    )
    mail(to: record.email)
  end

  def email_changed(record, _opts = {})
    set_template(EMAIL_CHANGED_TEMPLATE_ID)

    set_personalisation(
      email_subject: 'Email changed',
      name: record.name,
      is_unconfirmed_email: record.unconfirmed_email? ? "Yes" : "No",
      is_not_unconfirmed_email: record.unconfirmed_email? ? "No" : "Yes",
      email: record.email
    )
    mail(to: record.email)
  end
end
