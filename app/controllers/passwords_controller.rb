class PasswordsController < Devise::PasswordsController
protected

  def after_sending_reset_password_instructions_path_for(_resource_name)
    check_email_password_reset_user_path
  end
end
