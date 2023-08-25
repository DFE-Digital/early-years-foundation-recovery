class MailJob < ApplicationJob
  class MailJobError < StandardError
  end

  def log_mail_job
    message = "#{self.class.name} contacted #{recipients.count} users"
    Sentry.capture_message(message, level: :info) if Rails.application.live?
    log(message)
  rescue NoMethodError, NameError
    raise MailJobError, "#{self.class.name}.recipients is required for this mail job"
  end
end
