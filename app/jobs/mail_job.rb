class MailJob < Que::Job
  self.exclusive_execution_lock = true
  def run
    log 'MailJob: Running'
    NudgeMail.new.call
  end
end
