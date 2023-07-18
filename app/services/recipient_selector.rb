module RecipientSelector
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

  # @param new_module [Training::Module]
  # @return [Array<User>]
  def new_module_recipients(new_module)
    all_modules = Training::Module.ordered.reject { |module_item| module_item == new_module || module_item.draft? }
    User.all.select do |user|
      all_modules.map(&:name).all? do |module_name|
        user.module_completed?(module_name)
      end
    end
  end

private

  # @return [Training::Module, nil]
  def new_module
    Training::Module.ordered.reject(&:draft?).find { |module_item| module_item.published_at >= 1.day.ago.beginning_of_day }
  end

  # @param user [User]
  # @return [Training::Module]
  def module_in_progress(user)
    mod_name = user.module_time_to_completion.find { |_k, v| v.zero? }.first
    Training::Module.find_by(name: mod_name).first
  end
end
