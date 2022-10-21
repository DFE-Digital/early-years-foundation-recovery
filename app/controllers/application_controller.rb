class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics_tracking_id

  default_form_builder(EarlyYearsRecoveryFormBuilder)

  include Tracking
  include Auditing

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

private

  # @see Auditing
  # @return [User]
  def current_user
    return bot if bot?

    super
  end

  # @see Auditing
  # @return [Boolean]
  def user_signed_in?
    return true if bot?

    super
  end
end
