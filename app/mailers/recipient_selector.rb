module RecipientSelector
  def complete_registration_recipients
    User.month_old.training_email_recipients.registration_incomplete
  end

  def start_training_recipients
    User.month_old.registration_complete.not_started_training
  end
end
