class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(_resource)
    extra_registrations_path
  end

  def after_inactive_sign_up_path_for(resource)
    check_email_user_path(id: resource)
  end
end
