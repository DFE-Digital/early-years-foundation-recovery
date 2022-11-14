module TimeoutHelper
  # @return [Integer] minutes until timeout (default 15)
  def timeout_duration
    Rails.configuration.user_timeout_minutes
  end

  # @return [Float] minutes until timeout modal appears (default 5)
  def timeout_idle
    Rails.configuration.user_timeout_idle_minutes
  end

  # @return [Float] minutes grace warning is visible (default 5)
  def timeout_grace
    Rails.configuration.user_timeout_grace_minutes
  end

  # @return [String]
  def timeout_active
    current_user.present?.to_s
  end
end
