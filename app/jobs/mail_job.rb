# Base class for NotifyMailer jobs
#
class MailJob < ApplicationJob
  # @param args [Array]
  # @return [Array<User>]
  def self.recipients(*args)
    scope_name = "#{name.underscore}_recipients"
    User.send(scope_name, *args)
  end

  # @return [Symbol]
  def self.template
    name.underscore.delete_suffix('_mail_job').to_sym
  end

  # @return [String]
  def self.template_id
    NotifyMailer::TEMPLATE_IDS[template]
  end

  # @return [Boolean]
  def self.enqueue?
    Types::Params::Bool[ENV.fetch('DELIVERY_QUEUE', Rails.env.production?)]
  end

  def run(*)
    log_recipient_count
    super
  end

private

  # @note Mailer arguments must be able to be serialised for delayed delivery
  # @param args [Array]
  # @return [Mail::Message, ActionMailer::MailDeliveryJob]
  def prepare_message(*args)
    message = NotifyMailer.send(self.class.template, *args)
    self.class.enqueue? ? message.deliver_later : message.deliver_now
  end

  def log_recipient_count
    log "#{self.class.recipients.count} recipients"
  end
end
