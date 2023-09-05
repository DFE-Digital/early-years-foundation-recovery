class MailJob < ApplicationJob
  class Error < StandardError
  end

  # @return [Array<User>]
  def self.recipients
    scope_name = "#{name.underscore}_recipients"
    User.send(scope_name)
  end

  def run(*)
    super

    log("#{self.class.name}: #{self.class.recipients.count} recipients")
  end
end
