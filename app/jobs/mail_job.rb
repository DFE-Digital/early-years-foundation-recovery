class MailJob < ApplicationJob
  class Error < StandardError
  end

  # @raise [MailJob::Error]
  def self.recipients
    raise Error, "#{name}.recipients is not defined"
  end

  def run(*)
    super

    log("#{self.class.name}: #{self.class.recipients.count} recipients")
  end
end
