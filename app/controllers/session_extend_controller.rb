class SessionExtendController < Devise::SessionsController
  before_action :authenticate_registered_user!, only: %i[check_session_timeout render_timeout]

  def extend_session
    response.headers['Etag'] = '' # clear etags to prevent caching
    render plain: ttl_to_timeout, status: :ok
  end

private

  def ttl_to_timeout
    return 0 if user_session.blank?

    Devise.timeout_in - (Time.zone.now.utc - last_request_time).to_i
  end

  def last_request_time
    user_session['last_request_at'].presence || 0
  end
end
