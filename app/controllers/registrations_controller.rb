class RegistrationsController < Devise::RegistrationsController
protected

  def after_inactive_sign_up_path_for(resource)
    check_email_confirmation_user_path(email: resource.email)
  end
end
