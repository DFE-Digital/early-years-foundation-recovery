class SettingsController < ApplicationController
  def show
    if template_valid?
      track('static_page')
      render template
    else
      render 'errors/not_found'
    end
  end

  def create
    set_analytics_preference

    if settings_params[:settings_updated].present?
      flash[:notice] = t(:flash, scope: 'cookie_policy', path: root_path)
    end

    redirect_to request_path
  end

private

  def set_analytics_preference
    cookies[:track_analytics] = {
      value: settings_params[:track_analytics],
      expires: 6.months.from_now,
      httponly: true,
    }
  end

  def request_path
    if URI(settings_params[:request_path]).relative?
      settings_params[:request_path]
    else
      settings_path
    end
  end

  # @return [ActionController::Parameters]
  def settings_params
    params.permit(:request_path, :track_analytics, :settings_updated)
  end

  # @return [Boolean]
  def template_valid?
    template_exists?(template, lookup_context.prefixes)
  end

  # @return [String]
  def template
    page_params[:id].underscore
  end

  # @return [String]
  def page_params
    params.permit(:id)
  end
end
