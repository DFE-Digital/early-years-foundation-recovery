class MailJob < Que::Job
  def run
    log 'MailJob: Running'
    NudgeMail.new.call
  end
end
