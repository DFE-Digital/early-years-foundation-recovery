class ContinueTrainingMailJob < ScheduledJob
  def run
    NudgeMail.new.continue_training
  end
end
