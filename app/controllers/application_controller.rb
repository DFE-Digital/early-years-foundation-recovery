class ApplicationController < ActionController::Base
  around_action :set_time_zone

  before_action :maintenance_page, if: :maintenance?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_analytics_tracking_id,
                :set_hotjar_site_id,
                :prepare_cms
  before_action :handle_refresh

  helper_method :current_user,
                :debug?

  default_form_builder ::FormBuilder

  include Auditing
  include Logging
  include Tracking

  def authenticate_registered_user!
    authenticate_user! unless user_signed_in?
    return true if current_user.registration_complete?

    redirect_to edit_registration_terms_and_conditions_path, notice: 'Please complete registration'
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

  def set_hotjar_site_id
    @hotjar_id = Rails.configuration.hotjar_site_id
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
    Time.use_zone(ENV['TZ'], &block)
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

  def handle_refresh
    # Check if the `refresh` parameter is present
    if params[:refresh]
      # Perform a page reload or any other logic you need
      redirect_to request.path, status: :found # Reload the page without the `refresh` parameter
    end
  end
end
