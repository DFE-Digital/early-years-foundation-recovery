class NotifyMailer < GovukNotifyRails::Mailer
  BLANK_TEMPLATE_ID="36555d23-b0e0-4c10-9b85-9c79c98eb1fe".freeze
  CONFIRMATION_TEMPLATE_ID="a44bc231-d779-41d8-a5e0-180497dfa711".freeze

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
end
