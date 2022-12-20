module TimeoutHelper
  # @return [Integer] minutes of inactivity until auto logout (default 25)
  def timeout_duration
    Rails.configuration.user_timeout_minutes
  end

  # @return [Time] when user will be logged out
  def timeout_time
    Time.zone.now.advance(minutes: timeout_duration).to_fs(:time)
  end

  # @param [Boolean] value to set timeout_aria_hidden cookie as
  def set_aria_hidden_cookie(input)
    cookies[:timeout_aria_hidden] = input
  end
  
  # @return [Boolean] value of timeout_aria_hidden cookie
  def get_aria_hidden_cookie
    cookies[:timeout_aria_hidden]
  end

  # @return [Integer] minutes until timeout modal appears (default 5)
  def timeout_warning
    Rails.configuration.user_timeout_warning_minutes
  end

  # @return [Integer] minutes modal should appears for (default 5)
  def timeout_modal
    Rails.configuration.user_timeout_modal_visible
  end

  # @return [String] "true" or "false"
  def timeout_active
    current_user.present?.to_s
  end
end
