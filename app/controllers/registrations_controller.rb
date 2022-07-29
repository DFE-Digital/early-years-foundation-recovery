class RegistrationsController < Devise::RegistrationsController
  # Patch to prevent user enumeration exploit by silencing the 'taken' error
  def create
    build_resource(sign_up_params)

    # "save!" would raise validation that email has already been taken
    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end

    # imitate success
    elsif resource.errors.one? && resource.errors.first.type.eql?(:taken)
      resource.errors.delete :email

      # TODO: log and respond to attempt
      @user = resource
      render 'user/check_email_confirmation', status: :unprocessable_entity

      resource.send_email_taken_notification

      track('email_address_taken', email: resource.email, ip: request.ip)
    else
      # always hide taken message
      resource.errors.delete(:email) if resource.errors.first.type.eql?(:taken)

      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

protected

  def after_inactive_sign_up_path_for(resource)
    check_email_confirmation_user_path(ref: resource.confirmation_token)
  end
end
