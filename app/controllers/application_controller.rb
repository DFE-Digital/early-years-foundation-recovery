class ApplicationController < ActionController::Base
  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    redirect_to extra_registrations_path, notice: "Please complete registration"
  end
end
