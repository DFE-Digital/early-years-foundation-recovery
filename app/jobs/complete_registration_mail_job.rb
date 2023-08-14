class CompleteRegistrationMailJob < DuplicateJobChecker
  def run
    Rails.logger.info('CompleteRegistrationMailJob running')
    NudgeMail.new.complete_registration
  end
end
