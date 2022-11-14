class SessionTimeoutController < Devise::SessionsController
  prepend_before_action :skip_timeout, only: %i[check_session_timeout render_timeout]
  before_action :authenticate_registered_user!

  # @note clear etags to prevent caching
  def check_session_timeout
    response.headers['Etag'] = ''
    render plain: ttl_to_timeout, status: :ok
  end

private

  # @see Rails.configuration.user_timeout_minutes
  # @return [Integer]
  def ttl_to_timeout
    return 0 if user_session.blank?

    Devise.timeout_in - (Time.zone.now.utc - last_request_time).to_i
  end

  # @return [Integer]
  def last_request_time
    user_session['last_request_at'].presence || 0
  end

  def skip_timeout
    request.env['devise.skip_trackable'] = true
  end
end
