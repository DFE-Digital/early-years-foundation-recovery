module RecipientSelector
  def complete_registration_recipients
    User.training_email_recipients.month_old.registration_incomplete
  end

  def start_training_recipients
    User.training_email_recipients.month_old.registration_complete.not_started_training
  end

  def continue_training_recipients
    recent_visits = Ahoy::Visit.where(started_at: 4.weeks.ago.end_of_day..Time.now)
    old_visits = Ahoy::Visit.month_old.reject { |visit| recent_visits.pluck(:user_id).include?(visit.user_id) }
    User.course_in_progress.select { |user| old_visits.pluck(:user_id).include?(user.id) }
  end

  def new_module_recipients
    new_module = Training::Module.ordered.reject(&:draft?).find { |module_item| module_item.published_at >= 1.day.ago.beginning_of_day }
    return [] unless new_module
    
    all_modules = Training::Module.ordered.reject { |module_item| module_item == new_module || module_item.draft? }
    User.all.select do |user|
      all_modules.map(&:name).all? do |module_name|
        user.module_completed?(module_name)
      end
    end
  end
end
