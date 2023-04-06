class TimeoutController < Devise::SessionsController
  prepend_before_action :skip_timeout, only: %i[check]

  # @see TimeoutHelper
  def timeout_user
    sign_out current_user
  end

  # @note clear etags to prevent caching
  def check
    response.headers['Etag'] = ''
    render plain: ttl_to_timeout, status: :ok
  end

  # tracks and therefore extends
  def extend
    check
  end

private

  # @see Rails.configuration.user_timeout_minutes
  # @return [Integer] seconds until timeout
  def ttl_to_timeout
    return 0 if user_session.blank?

    Devise.timeout_in - (Time.zone.now.utc - last_request_time).to_i
  end

  # @return [Integer]
  def last_request_time
    user_session['last_request_at'].presence || 0
  end

  # Prevent tracking of timeout timer value
  def skip_timeout
    request.env['devise.skip_trackable'] = true
  end
end
