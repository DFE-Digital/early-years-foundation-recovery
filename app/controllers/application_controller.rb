class ApplicationController < ActionController::Base
  around_action :set_time_zone

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics_tracking_id,
                :set_hotjar_site_id,
                :prepare_cms

  helper_method :current_user,
                :timeout_timer,
                :debug?

  default_form_builder(EarlyYearsRecoveryFormBuilder)

  include Tracking
  include Auditing

  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    redirect_to edit_registration_name_path, notice: 'Please complete registration'
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

  # @return [Symbol]
  def prepare_cms
    # ensure correct API for each request
    ContentfulModel.use_preview_api = Rails.application.preview?
    # memoise the latest release timestamp
    Training::Module.reset_cache_key!
    :done
  end

  def set_analytics_tracking_id
    @tracking_id = Rails.configuration.google_analytics_tracking_id
  end

  def set_hotjar_site_id
    @hotjar_id = Rails.configuration.hotjar_site_id
  end

  # @return [Boolean] do not run accessibility tests with debug panels visible
  def debug?
    Rails.application.debug? && !bot?
  end

  def timeout_timer
    timeout_controller = TimeoutController.new
    timeout_controller.request = request
    timeout_controller.response = response
    timeout_controller.send(:ttl_to_timeout)
  end

private

  def set_time_zone(&block)
    Time.use_zone(ENV['TZ'], &block)
  end

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
