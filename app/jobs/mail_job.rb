# Base class for NotifyMailer jobs
#
class MailJob < ApplicationJob
  # @return [Array<User>]
  def self.recipients
    scope_name = "#{name.underscore}_recipients"
    User.send(scope_name)
  end

  # @return [Symbol]
  def self.template
    name.underscore.delete_suffix('_mail_job').to_sym
  end

  # @return [String]
  def self.template_id
    NotifyMailer::TEMPLATE_IDS[template]
  end

  def run(*)
    log "#{self.class.recipients.count} recipients"

    super
  end

private

  # @param args [Array]
  # @return [Mail::Message, ActionMailer::MailDeliveryJob]
  def prepare_message(*args)
    message = NotifyMailer.send(self.class.template, *args)
    enqueue? ? message.deliver_later : message.deliver_now
  end

  # @return [Boolean]
  def enqueue?
    Types::Params::Bool[ENV.fetch('DELIVERY_QUEUE', Rails.env.production?)]
  end
end
