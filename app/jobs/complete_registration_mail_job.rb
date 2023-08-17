class CompleteRegistrationMailJob < ScheduledJob
  def run
    NudgeMail.new.complete_registration
  end
end
