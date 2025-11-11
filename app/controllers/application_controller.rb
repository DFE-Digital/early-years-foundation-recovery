class ApplicationController < ActionController::Base
  around_action :set_time_zone

  before_action :maintenance_page, if: :maintenance?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics_tracking_id,
                :prepare_cms

  helper_method :current_user,
                :debug?

  default_form_builder ::FormBuilder

  include Auditing
  include Logging
  include Tracking

  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    if current_user.terms_and_conditions_agreed_at.nil?
      flash[:important] = terms_and_conditions_notification
      redirect_to edit_registration_terms_and_conditions_path
    else
      flash[:important] = complete_registration_notification
      # Redirect to last incomplete registration step
      registration_path_redirect
    end
  end

  def registration_path_redirect
    path = edit_registration_training_emails_path if current_user.training_emails.nil?
    path = edit_registration_early_years_experience_path if current_user.early_years_experience.nil?
    path = edit_registration_setting_type_path if current_user.setting_type.nil?

    redirect_to path
  end

  def complete_registration_notification
    key = 'complete_user_registration'

    notice = I18n.t(key, options: :flash)
    if notice.is_a?(Hash)
      notice.deep_symbolize_keys
    else
      notice
    end
  end

  def terms_and_conditions_notification
    key = 'terms_and_conditions'

    notice = I18n.t(key, options: :flash)
    if notice.is_a?(Hash)
      notice.deep_symbolize_keys
    else
      notice
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:terms_and_conditions_agreed_at])
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

  # @return [Boolean] do not run accessibility tests with debug panels visible
  def debug?
    Rails.application.debug? && !bot?
  end

private

  # @return [Boolean]
  def maintenance?
    return false if Rails.configuration.protected_endpoints.include?(request.path)

    Rails.application.maintenance?
  end

  def maintenance_page
    redirect_to static_path('maintenance')
  end

  def set_time_zone(&block)
    time_zone = ENV['TZ'] || Time.zone_default.name

    if valid_time_zone?(time_zone)
      Time.use_zone(time_zone, &block)
    else
      Rails.logger.warn("Invalid time zone '#{time_zone}' specified. Falling back to default time zone.")
      Time.use_zone(Time.zone_default.name, &block)
    end
  end

  # @see Auditing
  # @return [User, nil]
  def current_user
    return bot if bot?

    super
  end

  # @return [Guest]
  def guest
    visit = Visit.find_by(visit_token: cookies[:course_feedback]) || current_visit || Visit.new
    Guest.new(visit: visit)
  end

  # @see Auditing
  # @return [Boolean]
  def user_signed_in?
    return false if current_user&.guest?
    return true if bot?

    super
  end
end

def valid_time_zone?(time_zone)
  ActiveSupport::TimeZone[time_zone].present?
end
