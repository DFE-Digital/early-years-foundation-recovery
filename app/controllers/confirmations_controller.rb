class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, (resource.registration_complete ? :confirmed : :activated))
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

protected

  def after_confirmation_path_for(resource_name, _resource)
    if signed_in?(resource_name)
      user_path
    else
      new_session_path(resource_name)
    end
  end

  def after_resending_confirmation_instructions_path_for(_resource_name)
    check_email_confirmation_user_path
  end
end
