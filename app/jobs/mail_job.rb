class MailJob < Que::Job
  include SchedulerHelper
  def run
    return if job_queued?

    NudgeMail.new.call
  end
end
