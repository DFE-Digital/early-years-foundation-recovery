module RecipientSelector
  def complete_registration_recipients    
    User.training_email_recipients.month_old.registration_incomplete
  end

  def start_training_recipients
    User.training_email_recipients.month_old.registration_complete.not_started_training
  end
end
