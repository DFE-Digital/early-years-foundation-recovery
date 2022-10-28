class SessionTimeoutController < Devise::SessionsController
  prepend_before_action :skip_timeout, only: [:check_session_timeout, :render_timeout]
  before_action :authenticate_registered_user!
  
  def check_session_timeout
    response.headers["Etag"] = "" # clear etags to prevent caching
    render plain: ttl_to_timeout, status: :ok
  end

  # def render_timeout
  #   if current_user.present? && user_signed_in?
  #     reset_session
  #     sign_out(current_user)
  #   end

  #   flash[:alert] = t("devise.failure.timeout", default: "Your session has timed out.")
  #   redirect_to sign_in
  # end

private

  def ttl_to_timeout
    return 0 if user_session.blank?
    puts 'Devise.timeout_in'
    puts Devise.timeout_in.seconds.in_minutes
    puts last_request_time  
    puts Devise.timeout_in - (Time.now.utc - last_request_time).to_i
    puts 'Devise.timeout_in'
    Devise.timeout_in - (Time.now.utc - last_request_time).to_i
  end

  def last_request_time
    user_session["last_request_at"].presence || 0
  end
  
  def skip_timeout
    request.env["devise.skip_trackable"] = true
  end
end