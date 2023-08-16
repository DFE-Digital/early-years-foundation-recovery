class NudgeMail
  # @return [void]
  def complete_registration
    complete_registration_recipients.each { |recipient| NotifyMailer.complete_registration(recipient) }
  end

  # @return [void]
  def start_training
    start_training_recipients.each { |recipient| NotifyMailer.start_training(recipient) }
  end

  # @return [void]
  def continue_training
    continue_training_recipients.each do |recipient|
      progress = recipient.course
      NotifyMailer.continue_training(recipient, progress.current_modules.first)
    end
  end

  # @param mod [TrainingModule]
  # @return [void]
  def new_module(mod)
    completed_available_modules.each { |recipient| NotifyMailer.new_module(recipient, mod) }
  end

private

  # @return [User::ActiveRecord_Relation]
  def complete_registration_recipients
    User.training_email_recipients.month_old_confirmation.registration_incomplete
  end

  # @return [Array<User>]
  def start_training_recipients
    User.training_email_recipients.month_old_confirmation.registration_complete.not_started_training
  end

  # @return [Array<User>]
  def continue_training_recipients
    recent_visits = Ahoy::Visit.where(started_at: 4.weeks.ago.end_of_day..Time.zone.now)
    old_visits = Ahoy::Visit.month_old.reject { |visit| recent_visits.pluck(:user_id).include?(visit.user_id) }
    User.course_in_progress.select { |user| old_visits.pluck(:user_id).include?(user.id) }
  end

  # @return [Array<User>]
  def completed_available_modules
    available_modules = PreviouslyPublishedModule.pluck(:name)
    User.training_email_recipients.select do |user|
      available_modules.all? { |mod| user.module_completed?(mod) }
    end
  end
end
