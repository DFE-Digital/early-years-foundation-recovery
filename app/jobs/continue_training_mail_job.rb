class ContinueTrainingMailJob < DuplicateJobChecker
  def run
    Rails.logger.info('ContinueTrainingMailJob running')
    NudgeMail.new.continue_training
  end
end
