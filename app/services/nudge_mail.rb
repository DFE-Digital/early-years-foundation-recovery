class NudgeMail
  # @return [void]
  def call
    complete_registration_recipients.each { |recipient| NotifyMailer.complete_registration(recipient) }
    start_training_recipients.each { |recipient| NotifyMailer.start_training(recipient) }
    continue_training_recipients.each { |recipient| NotifyMailer.continue_training(recipient, module_in_progress(recipient)) }
  end

private

  # @return [ActiveRecord::Relation]
  def complete_registration_recipients
    User.training_email_recipients.month_old.registration_incomplete
  end

  # @return [ActiveRecord::Relation]
  def start_training_recipients
    User.training_email_recipients.month_old.registration_complete.not_started_training
  end

  # @return [Array<User>]
  def continue_training_recipients
    recent_visits = Ahoy::Visit.where(started_at: 4.weeks.ago.end_of_day..Time.zone.now)
    old_visits = Ahoy::Visit.month_old.reject { |visit| recent_visits.pluck(:user_id).include?(visit.user_id) }
    User.course_in_progress.select { |user| old_visits.pluck(:user_id).include?(user.id) }
  end

  # @param user [User]
  # @return [Training::Module]
  def module_in_progress(user)
    mod_name = user.module_time_to_completion.find { |_k, v| v.zero? }.first
    TrainingModule.find_by(name: mod_name)
  end
end
