class ConfirmationsController < Devise::ConfirmationsController
protected

  def after_resending_confirmation_instructions_path_for(_resource_name)
    check_email_confirmation_user_path
  end
end
