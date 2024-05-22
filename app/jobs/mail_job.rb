class MailJob < ApplicationJob
  # @return [Array<User>]
  def self.recipients
    scope_name = "#{name.underscore}_recipients"
    User.send(scope_name)
  end

  def run(*)
    log "#{self.class.recipients.count} recipients"

    super
  end
end
