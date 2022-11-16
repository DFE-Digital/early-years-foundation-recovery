module TimeoutHelper
  # @return [Integer] minutes of inactivity until auto logout (default 25)
  def timeout_duration
    Rails.configuration.user_timeout_minutes
  end

  # @return [Integer] minutes until timeout modal appears (default 5)
  def timeout_warning
    Rails.configuration.user_timeout_warning_minutes
  end

  # @return [String] "true" or "false"
  def timeout_active
    current_user.present?.to_s
  end
end
