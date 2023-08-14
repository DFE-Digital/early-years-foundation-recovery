class StartTrainingMailJob < DuplicateJobChecker
  def run
    Rails.logger.info('StartTrainingMailJob running')
    NudgeMail.new.start_training
  end
end
