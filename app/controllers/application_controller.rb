class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics_tracking_id

  default_form_builder(EarlyYearsRecoveryFormBuilder)

  # Record user event
  #
  # @param key [String]
  # @param data [Hash]
  #
  # @return [Boolean]
  def track(key, **data)
    properties = {
      path: request.fullpath,     # user perspective
      **request.path_parameters,  # developer perspective
      **data,
    }
    ahoy.track(key, properties)
  end

  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    redirect_to extra_registrations_path, notice: 'Please complete registration'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_and_conditions_agreed_at])
    update_attrs = %i[password password_confirmation current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  # @return [nil]
  def clear_flash
    flash[:alert] = nil
    flash[:error] = nil
  end

  def set_analytics_tracking_id
    @tracking_id = Rails.configuration.google_analytics_tracking_id
  end
end
