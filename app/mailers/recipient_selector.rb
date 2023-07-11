module RecipientSelector
  def complete_registration_recipients
    User.month_old.training_email_recipients.registration_incomplete.training_email_recipients
  end

  def start_training_recipients
    User.month_old.registration_complete.not_started_training.training_email_recipients
  end
end
