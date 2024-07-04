class NotifyMailer < GovukNotifyRails::Mailer
  after_deliver :log_delivery

  # @return [Hash<Symbol => String>]
  TEMPLATE_IDS = {
    account_closed: '0a4754ee-6175-444c-98a1-ebef0b14e7f7',
    account_closed_internal: 'a2dba0ef-84f1-4b4d-b50a-ce953050798e',
    complete_registration: 'b960eb6a-d183-484b-ac3b-93ae01b3cee1',
    continue_training: '83dd3dc6-c5de-4e32-a6b4-25c76e805d87',
    new_module: '2352b6ce-a098-47f0-870a-286308b9798f',
    start_training: 'b3c2e4ff-da06-4672-8941-b2f50d37eadc',
    test_bulk: '7c5fa953-4208-4bc4-919a-4ede23db65c1',
  }.freeze

  # @param user [User]
  # @return [Mail::Message]
  def test_bulk(user)
    set_template TEMPLATE_IDS[:test_bulk]
    set_personalisation(
      name: user.name,
      url: root_url,
      email: user.email,
      domain: ENV['DOMAIN'],
      env: ENV['ENVIRONMENT'],
    )
    mail(to: user.email)
  end

  # @param user [User]
  # @return [Mail::Message]
  def account_closed(user)
    set_template TEMPLATE_IDS[:account_closed]
    set_personalisation(
      name: user.name,
      email: user.email,
    )
    mail(to: user.email)
  end

  # @param user [User]
  # @return [Mail::Message]
  def account_closed_internal(user)
    set_template TEMPLATE_IDS[:account_closed_internal]
    set_personalisation(
      user_email_address: user.email,
      email: Course.config.internal_mailbox,
    )
    mail(to: Course.config.internal_mailbox)
  end

  # @param user [User]
  # @return [Mail::Message]
  def complete_registration(user)
    set_template TEMPLATE_IDS[:complete_registration]
    set_personalisation(
      url: root_url,
    )
    mail(to: user.email)
  end

  # @param user [User]
  # @return [Mail::Message]
  def start_training(user)
    set_template TEMPLATE_IDS[:start_training]
    set_personalisation(
      url: root_url,
    )
    mail(to: user.email)
  end

  # @param user [User]
  # @param mod [Training::Module]
  # @return [Mail::Message]
  def continue_training(user, mod)
    set_template TEMPLATE_IDS[:continue_training]
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      url: root_url,
    )
    mail(to: user.email)
  end

  # @see https://apidock.com/rails/v7.1.3.2/ActiveJob/SerializationError
  #
  # @param user [User]
  # @param mod [Training::Module]
  # @return [Mail::Message]
  def new_module(user, mod)
    set_template TEMPLATE_IDS[:new_module]
    set_personalisation(
      mod_number: mod.position,
      mod_name: mod.title,
      mod_criteria: mod.criteria,
      url: root_url,
    )
    mail(to: user.email)
  end

private

  # @note
  #   Avoid deploying mailer changes when scheduled mail jobs will run.
  #
  #   Background worker deployment is not gated therefore database migrations
  #   that impact after_deliver callbacks can potentially raise errors until the
  #   web app is released.
  #
  # @return [MailEvent, nil]
  def log_delivery
    if (user = User.find_by(email: Array(message.to).first))
      MailEvent.create!(
        user: user,
        template: govuk_notify_template,
        personalisation: govuk_notify_personalisation,
      )
    end
  end
end
