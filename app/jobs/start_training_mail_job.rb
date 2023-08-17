class StartTrainingMailJob < ScheduledJob
  def run
    NudgeMail.new.start_training
  end
end
