class PasswordsController < Devise::PasswordsController
protected

  def after_sending_reset_password_instructions_path_for(_resource_name)
    check_email_user_path
  end
end
